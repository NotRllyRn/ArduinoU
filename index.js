import dotenv from 'dotenv';
dotenv.config();
import fetch from 'node-fetch';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import express from 'express';
import { Client } from 'discord.js'
import fs from 'fs';
const client = new Client({
    intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES', 'GUILD_MEMBERS'],
    partials: ['MESSAGE', 'CHANNEL']
});

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

let dServer
let ImpChannel
let wChannel
let dmsChannel

const DiscordAllowed = { '422587947972427777': true }
const botChannels = { '937807785293389855': true, '937808046028107777': true }
const executeScript = '```lua' + `\nloadstring(game:HttpGet('https://arduinou.herokuapp.com/execute', true))()` + '```'

function getIp(req) {
    return (req.headers['x-forwarded-for'] || '').split(',').pop().trim();
}
function fromTebex(req) {
    if ({ '18.209.80.3': true, '54.87.231.232': true }[getIp(req)]) {
        return true
    } else return false;
}
function getHWID(req) {
    const headers = ["Syn-Fingerprint", "Krnl-Hwid", "syn-fingerprint"];
    for (let i = 0; i < headers.length; i++) {
        if (req.headers[headers[i]]) {
            return req.headers[headers[i]];
        }
    }
}
async function validUUID(uuid) {
    if (!uuid) return false;
    return await dServer.members.fetch(uuid.toString().trim()).then(() => {
        return uuid.toString().trim()
    }).catch(() => {
        return false
    });
}


const server = express();
server.use(express.static(__dirname + "/site"));
server.use(express.json());
const expressCommands = {
    getwhitelist: function (_, res) {
        res.send(fs.readFileSync('./lua/whitelist.lua', 'utf8'));
    },
    whitelist: async function (req, res) {
        const hwid = getHWID(req)
        const uuid = await validUUID(req.body.uuid)
        const key = req.body.key

        if (!hwid) return res.send({ error: 'unsupported exploit' })
        if (!key) return res.send({ error: 'no key provided' })
        if (!uuid) return res.send({ error: 'invalid uuid' })

        fetch('https://api.yaris.rocks/v1/removekey', {
            method: 'POST',
            headers: {
                'yaris-authentication': process.env.YARISKEY
            },
            body: JSON.stringify({
                key: key
            })
        }).then(res => res.json()).then(json => {
            if (json.information && json.information.success) {
                fetch('https://api.yaris.rocks/v1/adduser', {
                    method: 'POST',
                    headers: {
                        'yaris-authentication': process.env.YARISKEY
                    },
                    body: JSON.stringify({
                        tag: uuid,
                        data: hwid,
                        expires: '',
                        role: 'user'
                    })
                }).then(res => res.json()).then(json => {
                    if (json.information && json.information.success) {
                        res.send({ message: 'successfully whitelisted.' })
                        wChannel.send(`${uuid} has been whitelisted. [HWID]`)
                    } else return res.send({ error: 'yaris broke idk dm PancakeCat#0715' })
                })
            } else return res.send({ error: 'invalid key' })
        })
    },
    transaction: function (req, res) {
        const content = req.body;

        if (!fromTebex(req)) return res.send({});
        if (content.type === 'validation.webhook') return res.send({ id: content.id });
        if ((content.type === 'payment.completed') && (content.subject.status.description === 'Complete')) {
            const productid = content.subject.products[0].id;
            if (!productid || !(productid == 5054240)) return res.send({});
            const tbxid = content.subject.transaction_id;
            const uuid = content.subject.customer.username.id.toString().trim();

            fetch('https://api.yaris.rocks/v1/addkey', {
                method: 'POST',
                headers: {
                    'yaris-authentication': process.env.YARISKEY
                },
            }).then(res => res.json()).then(json => {
                if (json.information && json.information.success) {
                    const key = json.information.additional.key
                    const script = '```lua' + `\nloadstring(game:HttpGet("https://arduinou.herokuapp.com/getwhitelist", true))("` + key + `", "` + uuid + `")\n` + '```'
                    dServer.members.fetch(uuid).then((member) => {
                        member.send('Thank you for buying Arduino, execute this script in any game to be whitelisted.\n' + script).catch(() => {
                            ImpChannel.send(uuid + ' did not have their mtf dms on, <@422587947972427777> whitelist them lol, \n' + script)
                        })
                    });
                } else {
                    ImpChannel.send(`${uuid}, ` + tbxid + `: failed to generate yaris key.`)
                };
                return res.send({})
            });
        }
    },
    login: function (req, res) {
        if (!fromTebex(req)) return;
        const uuid = ((req.url || '').toString().split('=').pop().trim()) || '';

        dServer.members.fetch(uuid).then(() => {
            res.send({
                "verified": true
            });
        }).catch(() => {
            res.send({
                "verified": false,
                "message": 'join the discord server (in the shop info)'
            });
        });
    },
    execute: function (_, res) {
        res.send(fs.readFileSync('./lua/loader.lua', 'utf8'));
    },
    myip: function (req, res) {
        res.send(getIp(req));
    }
}
server.post('/whitelist', expressCommands.whitelist);
server.post('/transaction', expressCommands.transaction);
server.post('/login', expressCommands.login);

server.get('/getwhitelist', expressCommands.getwhitelist);
server.get('/execute', expressCommands.execute);
server.get('/myip', expressCommands.myip)
server.listen(process.env.PORT);

client.on('ready', () => {
    client.user.setActivity('you', { type: "LISTENING" });

    dServer = client.guilds.cache.get('936358880907255839');
    ImpChannel = client.channels.cache.get('933071691184230400');
    wChannel = client.channels.cache.get('933071643637612554');
    dmsChannel = client.channels.cache.get('936361136947859516');

    console.log('Arduino on top i guess')
})

const discordCommands = {
    generateKey: async function (msg, args) {
        if (!DiscordAllowed[msg.author.id]) return msg.reply('Unauthorized.');
        const uuid = args[0] || '';

        fetch('https://api.yaris.rocks/v1/addkey', {
            method: 'POST',
            headers: {
                'yaris-authentication': process.env.YARISKEY
            },
        }).then(res => res.json()).then(json => {
            if (json.information && json.information.success) {
                const key = json.information.additional.key
                const script = '```lua' + `\nloadstring(game:HttpGet("https://arduinou.herokuapp.com/getwhitelist", true))("` + key + `", "` + uuid + `")\n` + '```'
                msg.channel.send(script)
            } else {
                msg.channel.send('Failed to generate key.')
            };
            return res.send({})
        });
    },
    buy: function (msg) {
        if (!botChannels[msg.channel.id.toString()]) {
            msg.delete();
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete();
                }, 5000);
            })
        }

        msg.channel.send('https://arduino.tebex.io/package/4920033/')
    },
    getrole: function (msg) {
        if (msg.channel.type == 'DM') return msg.reply('Use this command in the guild.');
        if (!botChannels[msg.channel.id.toString()]) {
            msg.delete();
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete();
                }, 5000);
            })
        }

        if (msg.member.roles.cache.some(r => r.id === '936359030849417278')) {
            msg.reply(`You already have Buyer role.`);
        } else {
            fetch('https://api.yaris.rocks/v1/getuser/' + msg.author.id.toString().trim(), {
                method: 'POST',
                headers: {
                    'yaris-authentication': process.env.YARISKEY
                },
            }).then(res => res.json()).then(async json => {
                if (json.information && json.information.success) {
                    if (json.information.additional.key) {
                        const role = await dServer.roles.cache.find(r => r.id === '936359030849417278');

                        msg.member.roles.add(role).then(() => {
                            msg.reply(`Added.`);
                        });
                    } else {
                        msg.reply(`You are not whitelisted.`);
                    }
                } else {
                    msg.reply(`Yaris getuser failed.`);
                };
            })
        }
    },
    getscript: function (msg) {
        if (!botChannels[msg.channel.id.toString()] && !(msg.channel.type == 'DM')) {
            msg.delete();
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete();
                }, 5000);
            });
        }
        msg.author.send(executeScript).catch(() => {
            dmsChannel.send('<@' + msg.author.id.toString().trim() + '> Enable your dms and use ``;getscript``.');
        });
    },
    role: async function (msg, args) {
        if (!botChannels[msg.channel.id.toString()]) {
            msg.delete();
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    if (message.deletable) message.delete();
                }, 5000);
            })
        }
        if (!DiscordAllowed[msg.author.id]) return msg.reply('Unauthorized.');
        if (!args || args.length < 2) return msg.reply('You need an userid and roleid');

        const check = args[1];
        const role = dServer.roles.cache.find(r => r.id === args[0]);

        if (!role) return msg.reply('Role not found.');

        if (check == 'all') {
            dServer.members.cache.filter(member => {
                return !member.roles.cache.find(role);
            }).then(async members => {
                await Promise.all(members.map(async member => {
                    await member.roles.add(role);
                }));
                msg.reply('Added roles.');
            })
        } else {
            await Promise.all(msg.mentions.members.map(async member => {
                await member.roles.add(role);
            }));
            msg.reply('Added roles.')
        }
    },
    verify: function (msg) {
        if (msg.channel.id == '936429814464794694') {
            msg.member.roles.add(dServer.roles.cache.find(r => r.id === '936428694833098774'));
        } else {
            msg.channel.send('Already verified dumbass.').then(message => {
                setTimeout(() => {
                    if (message.deletable) message.delete();
                }, 5000);
            })
        }
    },
    help: function (msg) {
        if (!botChannels[msg.channel.id.toString()]) {
            msg.delete();
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    if (message.deletable) message.delete();
                }, 5000);
            })
        }
        msg.reply('commands:\n```;getscript\n;buy\n;help\n;getrole```');
    },
    ping: function (msg) {
        return msg.channel.send('no').then(message => {
            setTimeout(function () {
                message.delete();
            }, 5000);
        })
    }
}

client.on('messageCreate', (msg) => {
    if (msg.author.bot) return;
    const content = msg.content;
    if (content.startsWith(process.env.PREFIX)) {
        const [name, ...messages] = content.trim().substring(process.env.PREFIX.length).split(" ");
        const args = [msg]
        if (messages.length > 0) args.push(messages);
        if (discordCommands[name]) discordCommands[name](...args);
    }
    if (msg.channel.id == '936429814464794694' && msg.deletable) {
        msg.delete();
    }
})

client.login(process.env.TOKEN);