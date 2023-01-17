require('dotenv').config(); 
const fetch = require('node-fetch');
const crypto = require("crypto");
const mysql = require('mysql');
const express = require('express');
const { Client } = require('discord.js');
const fs = require('fs'); 
const client = new Client({
    intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES', 'GUILD_MEMBERS'],
    partials: ['MESSAGE', 'CHANNEL']
});
const sql = mysql.createConnection({
    host: process.env.DBURL,
    user: process.env.DBUSER,
    password: process.env.DBPASS,
    port: 3306,
    database: 'main'
});

const DiscordAllowed = {
    '422587947972427777': true
}
const botChannels = {
    '937807785293389855': true,
    '937808046028107777': true
}
let dServer;
const executeScript = '```lua' + `
key = ''

loadstring(game:HttpGet('https://arduinou.herokuapp.com/loader', true))()` + '```'

function hasher(v) {
    const hased = crypto.createHash('sha3-256').update(v).digest('hex');
    return hased
}
function getIp(req) {
    return (req.headers['x-forwarded-for'] || '').split(',').pop().trim();
}
function fromTebex(req) {
    if (!({ '18.209.80.3': true, '54.87.231.232': true }[getIp(req)])) {
        return true
    } else return false;
}

sql.connect(async function (err) {
    if (err) {
        await client.channels.cache.get('933071691184230400').send('SQL error:```' + err + '```');
        throw err;
    }
    console.log('Mysql Connected.');
});

const server = express();
server.use(express.static(__dirname + "/site"));
server.use(express.json());
const expressCommands = {
    whitelistCheck: function (req, res) {
        const content = req.body;
        const objects = content.object;
        const wkey = content.key;
        const check = objects.toString().trim().split('');
        const pass = ((parseInt(check[1]) % 2) == 0) ? true : false;

        sql.query('SELECT * FROM whitelist WHERE wkey = ?', [wkey], function (err, result) {
            if (err) return res.send({ Whitelisted: false, object: true }), expressCommands.mainCheck(req, res);

            if (result.length === 1) {
                res.send({ Whitelisted: true, object: pass });
                client.channels.cache.get('933054025040031774').send('[``' + wkey + '``] Script executed.');
            } else expressCommands.mainCheck(req, res);
        })
    },
    mainCheck: function (req, res) {
        const content = req.body;
        const objects = content.object;
        const wkey = content.key;
        const ip = hasher(getIp(req));
        const hwid = hasher(req.headers['syn-fingerprint']);
        const check = objects.toString().trim().split('');
        const pass = ((parseInt(check[1]) % 2) == 0) ? true : false;

        sql.query('SELECT * FROM tbxkeys WHERE wkey = ?', [wkey], function (err, data) {
            if (err) return res.send({ Whitelisted: false, object: true });
            if (data.length !== 1) return res.send({ Whitelisted: false, object: true });

            if (data[0].ip === ip) {
                if (!data[0].hwid) {
                    sql.query('UPDATE tbxkeys SET ? WHERE wkey = ?', [
                        { hwid: hwid },
                        wkey
                    ], function (err) {
                        if (err) return;
                    });
                    res.send({ Whitelisted: true, object: pass });
                    client.channels.cache.get('933054025040031774').send('Script executed by ``' + data[0].userid + '``');
                } else if (data[0].hwid === hwid) {
                    res.send({ Whitelisted: true, object: pass });
                    client.channels.cache.get('933054025040031774').send('Script executed by ``' + data[0].userid + '``');
                } else {
                    res.send({ Whitelisted: false, object: true });
                    client.channels.cache.get('933071691184230400').send('Hwid change detected from ``' + data[0].userid + '``');
                }
            } else {
                res.send({ Whitelisted: false, object: true });
                client.channels.cache.get('933071691184230400').send('Ip change detected from ``' + data[0].userid + '``');
            }
        })
    },
    blacklistCheck: function (req, res) {
        const ip = hasher(getIp(req));
        const hwid = hasher(req.headers['syn-fingerprint']);

        sql.query('SELECT * FROM blacklisted WHERE ip = ? OR hwid = ?', [ip, hwid], function (err, result) {
            if (err) return res.send({ Whitelisted: false, object: true });

            if (result.length === 1) return res.send({ Whitelisted: false, object: true }); else expressCommands.whitelistCheck(req, res);
        })
    },
    checker: function (req, res) {
        const content = req.body;
        const objects = content.object;
        let ip = getIp(req);
        let hwid = req.headers['syn-fingerprint'];

        if (!ip || !hwid || !content || !objects || !(new String(objects).length == 3)) return res.send({ Whitelisted: false, object: true });
        ip = hasher(ip);
        hwid = hasher(hwid);
        const check = objects.toString().trim().split('').pop();

        if ((parseInt(check) % 2) == 0) return res.send({ Whitelisted: false, object: false });

        expressCommands.blacklistCheck(req, res);
    },
    transaction: function (req, res) {
        const content = req.body;

        if (fromTebex(req)) return;
        if (content.type === 'validation.webhook') return res.send({ id: content.id });

        if ((content.type === 'payment.completed') && (content.subject.status.description === 'Complete')) {
            const productid = content.subject.products[0].id;
            if (!productid || !(productid == 4920033)) return res.send({});
            const tbxid = content.subject.transaction_id;
            const ip = hasher(content.subject.customer.ip);
            const userid = content.subject.customer.username.id.toString().trim();
            let wkey = crypto.randomBytes(12).toString("hex");

            function checkkey() {
                sql.query(`SELECT * FROM tbxkeys WHERE wkey = ? OR tbxid = ?`, [wkey, tbxid], function (err, data) {
                    if (err) return res.send({});
                    if (data.length !== 0) {
                        if (data[0].wkey === wkey) {
                            wkey = crypto.randomBytes(12).toString("hex");
                            checkkey();
                        } else res.send({});
                    } else {
                        sql.query('INSERT INTO tbxkeys SET ?', {
                            tbxid: tbxid,
                            wkey: wkey,
                            ip: ip,
                            whitelist: true,
                            userid: userid
                        }, function (err) {
                            if (err) return res.send({}); else {
                                const uuid = content.subject.customer.username.username.toString().trim();
                                client.channels.cache.get('933071643637612554').send(
                                    '``' + uuid + '`` Whitelisted.\n'
                                    + 'TbxID: ``' + tbxid + '``\n'
                                    + 'UserID: ``' + userid + '``'
                                );
                                dServer.members.fetch(userid).then((member) => {
                                    member.roles.add(dServer.roles.cache.find(r => r.id === '936359030849417278'));
                                    member.send('Key: ``' + wkey + '``').catch(() => {
                                        client.channels.cache.get('936361136947859516').send('<@' + userid + '> Enable your dms and use ``;getkey``.');
                                    });
                                }).catch(() => {
                                    client.channels.cache.get('933071691184230400').send('``' + userid + '`` was not in server when buying.\n``' + tbxid + '``');
                                });

                                res.send({});
                            }
                        });
                    }
                });
            }
            checkkey();
        }
    },
    login: function (req, res) {
        if (fromTebex(req)) return;
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
    loader: function (req, res) {
        res.send(fs.readFileSync('./lua/loader.lua', 'utf8'));
    }
}
server.post('/execute', function (req, res) {
    expressCommands.checker(req, res);
});
server.post('/transaction', function (req, res) {
    expressCommands.transaction(req, res);
});
server.get('/login', function (req, res) {
    expressCommands.login(req, res);
});
server.get('/loader', function (req, res) {
    expressCommands.loader(req, res);
});
server.get('/myip', function (req, res) {
    res.send(getIp(req));
})
server.get('/test', function(req, res){
    res.send('print("test")');
    console.log(getIp(req));
})
server.listen(process.env.PORT);

let discordCommands = {
    sql: function (msg, args) {
        if (msg.channel.type !== 'DM') {
            msg.delete();
            msg.author.send('That command is not allowed to be used in public channels.').catch(() => {
                msg.channel.send("<@" + msg.author.id + "> Please enable your dm's & use the command there.")
            });
            return
        }
        if (!DiscordAllowed[msg.author.id]) return msg.reply('Unauthorized.');
        if (!args || args.length < 1) return msg.reply('You need an sql command.');

        sql.query(args.join(' '), function (err, data) {
            if (err) {
                msg.reply(err.toString());
            } else {
                msg.reply('```js\n' + JSON.stringify(data, null, ' ') + '```');
            }
        });
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
            client.channels.cache.get('936361136947859516').send('<@' + msg.author.id.toString().trim() + '> Enable your dms and use ``;getscript``.');
        });
    },
    getkey: function (msg) {
        if (!botChannels[msg.channel.id.toString()] && !(msg.channel.type == 'DM')) {
            msg.delete();
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete();
                }, 5000);
            })
        }
        sql.query('SELECT * FROM tbxkeys WHERE userid = ?', [msg.author.id.toString().trim()], function (err, data) {
            if (err) return msg.reply('Bot errored.');
            if (data.length > 0) {
                msg.author.send('Key: ``' + data[0].wkey + '``').catch(() => {
                    client.channels.cache.get('936361136947859516').send('<@' + msg.author.id.toString().trim() + '> Enable your dms and use ``;getkey``.');
                });
            } else {
                msg.reply('You are not whitelisted. Use ``;buy`` to buy a key.');
            }
        })
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
            sql.query(`SELECT * FROM tbxkeys WHERE userid = ?`, [msg.author.id.toString().trim()], function (err, data) {
                if (err) return msg.reply('An error occoured.');
                if (data.length > 0) {
                    msg.member.roles.add(dServer.roles.cache.find(r => r.id === '936359030849417278'));
                    msg.reply('Role added.');
                } else {
                    msg.reply('You are not whitelisted.');
                }
            })
        }
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

        msg.channel.send('https://arduino.tebex.io/')
    },
    whitelist: function (msg, args) {
        if (msg.channel.type !== 'DM') {
            msg.delete();
            msg.author.send('That command is not allowed to be used in public channels.').catch(() => {
                msg.channel.send("<@" + msg.author.id + "> Please enable your dm's & use the command there.")
            });
            return
        }
        if (!DiscordAllowed[msg.author.id]) return msg.reply('Unauthorized.');
        if (!args || args.length < 2) return msg.reply('You need an ip and userid');

        const ip = hasher(args[0]);
        const userid = args[1];
        const tbxid = 'tbx-' + crypto.randomBytes(8).toString("hex") + '-fake'
        let wkey = crypto.randomBytes(12).toString("hex");

        function checkkey() {
            sql.query(`SELECT * FROM tbxkeys WHERE wkey = ?`, [wkey], function (err, data) {
                if (err) return msg.reply('error in 1st query');
                if (data.length !== 0) {
                    if (data[0].wkey === wkey) {
                        wkey = crypto.randomBytes(12).toString("hex");
                        checkkey();
                    } else return msg.reply('Key is not the same but got a result?');
                } else {
                    sql.query('INSERT INTO tbxkeys SET ?', {
                        tbxid: tbxid,
                        wkey: wkey,
                        ip: ip,
                        whitelist: true,
                        userid: userid
                    }, function (err) {
                        if (err) return msg.reply('error in 2nd query, trying to inser'); else {
                            dServer.members.fetch(userid).then((member) => {
                                member.roles.add(dServer.roles.cache.find(r => r.id === '936359030849417278'));
                                member.send('Key: ``' + wkey + '``').catch(() => {
                                    client.channels.cache.get('936361136947859516').send('<@' + userid + '> Enable your dms and use ``;getkey``.');
                                });
                            }).catch(() => {
                                return msg.reply('User not found.\n ```' + wkey + '```');
                            });

                            msg.reply('Whitelist successful.\n ```' + wkey + '```');
                        }
                    });
                }
            });
        }
        checkkey();
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
            dServer.members.fetch().then(async members => {
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
        msg.reply('commands:\n```;getkey\n;getscript\n;buy\n;help\n;getrole```');
    },
    ping: function (msg) {
        return msg.channel.send('no').then(message => {
            setTimeout(function () {
                message.delete();
            }, 5000);
        })
    }
}
client.on("ready", () => {
    client.user.setActivity('you', { type: "LISTENING" });
    dServer = client.guilds.cache.get('936358880907255839');
    console.log('Discord bot Active.');
});
client.on('messageCreate', (msg) => {
    if (msg.author.bot) return;
    const content = msg.content;
    if (content.startsWith(process.env.PREFIX)) {
        const [name, ...args] = content
            .trim()
            .substring(process.env.PREFIX.length)
            .split(" ");
        const insert = [msg]
        if (args.length > 0) insert.push(args);
        if (discordCommands[name]) discordCommands[name](...insert);
    }
    if (msg.channel.id == '936429814464794694' && msg.deletable) {
        msg.delete();
    }
})
client.login(process.env.DISCORD_TOKEN);