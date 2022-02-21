require('dotenv').config()
const crypto = require("crypto");
const mysql = require('mysql')
const express = require('express')
const { Client } = require('discord.js');
const fs = require('fs')
const client = new Client({
    intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES'],
    partials: ['MESSAGE', 'CHANNEL']
})

const DiscordAllowed = {
    '422587947972427777': true
}
const botChannels = {
    '937807785293389855': true,
    '937808046028107777': true
}
let dServer;
const executeScript = `key = ''

loadstring(game:HttpGet('https://arduinou.herokuapp.com/loader', true))()`

function hasher(v) {
    let hased = crypto.createHash('sha3-256').update(v).digest('hex')
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

let sql = mysql.createConnection({
    host: process.env.DBURL,
    user: process.env.DBUSER,
    password: process.env.DBPASS,
    port: 3306,
    database: 'main'
})
sql.connect(function (err) {
    if (err) throw err;
    console.log('Mysql Connected.')
});

const server = express()
server.use(express.static(__dirname + "/site"));
server.use(express.json());
let expressCommands = {
    whitelistCheck: function (req, res) {
        let content = req.body;
        let objects = content.object;
        let wkey = content.key;
        let check = objects.toString().trim().split('')
        let pass = ((parseInt(check[1]) % 2) == 0) ? true : false

        sql.query('SELECT * FROM whitelist WHERE wkey = ?', [wkey], function (err, result) {
            if (err) return res.send({ Whitelisted: false, object: true }), expressCommands.mainCheck(req, res);

            if (result.length === 1) {
                res.send({ Whitelisted: true, object: pass })
                client.channels.cache.get('933054025040031774').send('[``' + wkey + '``] Script executed.');
            } else expressCommands.mainCheck(req, res);
        })
    },
    mainCheck: function (req, res) {
        let content = req.body;
        let objects = content.object;
        let wkey = content.key;
        let ip = hasher(getIp(req));
        let hwid = hasher(req.headers['syn-fingerprint']);
        let check = objects.toString().trim().split('')
        let pass = ((parseInt(check[1]) % 2) == 0) ? true : false

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
                client.channels.cache.get('933071691184230400').send('Ip change detected from ``' + data[0].userid + '``')
            }
        })
    },
    blacklistCheck: function (req, res) {
        let ip = getIp(req);
        let hwid = req.headers['syn-fingerprint'];
        ip = hasher(ip);
        hwid = hasher(hwid);

        sql.query('SELECT * FROM blacklisted WHERE ip = ? OR hwid = ?', [ip, hwid], function (err, result) {
            if (err) return res.send({ Whitelisted: false, object: true });

            if (result.length === 1) return res.send({ Whitelisted: false, object: true }); else expressCommands.whitelistCheck(req, res);
        })
    },
    checker: function(req,res) {
        let content = req.body;
        let objects = content.object;
        let ip = getIp(req);
        let hwid = req.headers['syn-fingerprint'];

        if (!ip || !hwid || !content || !objects || !(new String(objects).length == 3)) return res.send({ Whitelisted: false, object: true });
        ip = hasher(ip);
        hwid = hasher(hwid);
        let check = objects.toString().trim().split('').pop()

        if (parseInt(check) % 2 == 0) return res.send({ Whitelisted: false, object: false })
        
        expressCommands.blacklistCheck(req, res)
    },
    transaction: function (req, res) {
        let content = req.body;

        if (fromTebex(req)) return;
        if (content.type === 'validation.webhook') return res.send({ id: content.id });

        if ((content.type === 'payment.completed') && (content.subject.status.description === 'Complete')) {
            let tbxid = content.subject.transaction_id;
            let ip = hasher(content.subject.customer.ip);
            let userid = content.subject.customer.username.id.toString().trim();
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
                                let uuid = content.subject.customer.username.username.toString().trim()
                                client.channels.cache.get('933071643637612554').send(
                                    '``' + uuid + '`` Whitelisted.\n'
                                    + 'TbxID: ``' + tbxid + '``\n'
                                    + 'UserID: ``' + userid + '``'
                                );
                                dServer.members.fetch(userid).then((member) => {
                                    member.roles.add(dServer.roles.cache.find(r => r.id === '936359030849417278'))
                                    member.send('Key: ``' + wkey + '``').catch(() => {
                                        client.channels.cache.get('936361136947859516').send('<@' + userid + '> Enable your dms and use ``;getkey``.')
                                    });
                                }).catch(() => {
                                    client.channels.cache.get('933071691184230400').send('``' + userid + '`` was not in server when buying.\n``' + tbxid + '``')
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
        let uuid = ((req.url || '').toString().split('=').pop().trim()) || '';

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
        if (!DiscordAllowed[msg.author.id]) return msg.reply('Unauthorized.')
        if (!args || args.length < 1) return msg.reply('You need an sql command.')

        sql.query(args.join(' '), function (err, data) {
            if (err) {
                msg.reply(err.toString())
            } else {
                msg.reply(JSON.stringify(data, null, ' '))
            }
        });
    },
    getscript: function (msg) {
        if (!botChannels[msg.channel.id.toString()] && !(msg.channel.type == 'DM')) {
            msg.delete()
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete()
                }, 5000);
            })
        }
        let userid = msg.author.id.toString().trim()

        sql.query('SELECT * FROM tbxkeys WHERE userid = ?', [userid], function (err, data) {
            if (err) return msg.reply('Bot errored.');
            if (data.length === 0) {
                msg.reply('You are not whitelisted.')
            } else if (data[0].whitelist.toString() === '1') {
                msg.author.send('``' + executeScript + '``').catch(() => {
                    client.channels.cache.get('936361136947859516').send('<@' + msg.author.id.toString().trim() + '> Enable your dms and use ``;getscript``.')
                });
            } else {
                msg.reply('You are not whitelisted.')
            }
        })
    },
    getkey: function (msg) {
        if (!botChannels[msg.channel.id.toString()] && !(msg.channel.type == 'DM')) {
            msg.delete()
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete()
                }, 5000);
            })
        }
        sql.query('SELECT * FROM tbxkeys WHERE userid = ?', [msg.author.id.toString().trim()], function (err, data) {
            if (err) return msg.reply('Bot errored.');
            if (data.length > 0) {
                msg.author.send('Key: ``' + data[0].wkey + '``').catch(() => {
                    client.channels.cache.get('936361136947859516').send('<@' + msg.author.id.toString().trim() + '> Enable your dms and use ``;getkey``.')
                });
            } else {
                msg.reply('You are not whitelisted.')
            }
        })
    },
    getrole: function (msg) {
        if (msg.channel.type == 'DM') return msg.reply('Use this command in the guild.');
        if (!botChannels[msg.channel.id.toString()]) {
            msg.delete()
            return msg.channel.send('<@' + msg.author.id + '> Please use bot commands in bot channels.').then(message => {
                setTimeout(function () {
                    message.delete()
                }, 5000);
            })
        }
        if (msg.member.roles.cache.some(r => r.id === '936359030849417278')) {
            msg.reply(`You already have Buyer role.`)
        } else {
            sql.query(`SELECT * FROM tbxkeys WHERE userid = ?`, [msg.author.id.toString().trim()], function (err, data) {
                if (err) return msg.reply('An error occoured.');
                if (data.length > 0) {
                    msg.member.roles.add(dServer.roles.cache.find(r => r.id === '936359030849417278'));
                    msg.reply('Role added.')
                } else {
                    msg.reply('You are not whitelisted.')
                }
            })
        }
    },
    ping: function (msg) {
        msg.reply('no')
    }
}
client.on("ready", () => {
    client.user.setActivity(`for sure`, { type: "LISTENING" });
    dServer = client.guilds.cache.get('936358880907255839');
    console.log('Discord bot Active.')
});
client.on('messageCreate', (msg) => {
    if (msg.author.bot) return;
    let content = msg.content
    if (content.startsWith(process.env.PREFIX)) {
        let [name, ...args] = content
            .trim()
            .substring(process.env.PREFIX.length)
            .split(" ");
        let insert = [
            msg,
        ]
        if (args.length > 0) {
            insert.splice(2, 0, args)
        }
        if (discordCommands[name]) {
            discordCommands[name](...insert)
        }
    }
})
client.login(process.env.DISCORD_TOKEN)