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

let DiscordAllowed = {
    '422587947972427777': true
}
let dServer;
let luaPath = './lua/'

function executeScript(res, id) {
    console.log(id)
    if (fs.existsSync(luaPath + id + '.lua')) {
        console.log('in')
        res.send(fs.accessSync(luaPath + id + '.lua'))
    }
}

function getIp(req) {
    let ip = (req.headers['x-forwarded-for'] || '').split(',').pop().trim();
    return ip
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
        let ip = getIp(req);
        let hwid = req.headers['syn-fingerprint'];

        if (!content || !ip || !hwid || !content.wkey || !content.gid) return res.send('warn("Invalid key.")');
        let wkey = content.wkey;
        let gid = content.gid;

        sql.query('SELECT * FROM whitelist WHERE wkey = ?', [wkey], function (err, result) {
            if (err) return res.send('warn("Bot errored.")'), expressCommands.mainCheck(req, res);

            if (result.length === 1) {
                executeScript(res, gid)
            } else expressCommands.mainCheck(req, res);
        })
    },
    mainCheck: function (req, res) {
        let content = req.body;
        let ip = getIp(req);
        let hwid = req.headers['syn-fingerprint'];

        if (!content || !ip || !hwid || !content.wkey || !content.gid) return res.send('warn("Invalid key.")');
        let wkey = content.wkey;
        let gid = content.gid

        sql.query('SELECT * FROM tbxkeys WHERE wkey = ?', [wkey], function (err, data) {
            if (err) return;
            if (data.length !== 1) return res.send('warn("Invalid key.")');

            if (data[0].ip === ip) {
                if (!data[0].hwid) {
                    sql.query('UPDATE tbxkeys SET ? WHERE wkey = ?', [
                        { hwid: hwid },
                        wkey
                    ], function (err) {
                        if (err) return;
                    });
                    executeScript(res, gid)
                    client.channels.cache.get('933054025040031774').send('Script executed by ``' + data[0].userid + '``.')
                } else if (data[0].hwid === hwid) {
                    executeScript(res, gid)
                    client.channels.cache.get('933054025040031774').send('Script executed by ``' + data[0].userid + '``.')
                } else {
                    res.send('warn("Detected hwid change")');
                    client.channels.cache.get('933071691184230400').send('Detected Change; ``' + data[0].userid + '``\n``' +
                        data[0].ip + ' < ' + ip + '``\n``' + data[0].hwid + ' < ' + hwid + '``'
                    );
                }
            } else {
                res.send('warn("Detected ip change.")');
                client.channels.cache.get('933071691184230400').send('Detected Change; ``' + data[0].userid + '``\n``' +
                    data[0].ip + ' < ' + ip + '``\n``' + data[0].hwid + ' < ' + hwid + '``'
                );
            }
        })
    },
    blacklistCheck: function (req, res) {
        let ip = getIp(req);
        let hwid = req.headers['syn-fingerprint'];
        let gid = req.body.gid

        if (!ip || !hwid || !gid) return res.send('warn("Executor not supported. (im just stupid aren`t i?)")');

        sql.query('SELECT * FROM blacklisted WHERE ip = ? OR hwid = ?', [ip, hwid], function (err, result) {
            if (err) return res.send('warn("Bot errored.")'), expressCommands.whitelistCheck(req, res);

            if (result.length === 1) return res.send(`warn("You're blacklisted.")`); else expressCommands.whitelistCheck(req, res);
        })
    },
    transaction: function (req, res) {
        let content = req.body;

        if (fromTebex(req)) return;
        if (content.type === 'validation.webhook') return res.send({ id: content.id });

        if ((content.type === 'payment.completed') && (content.subject.status.description === 'Complete')) {
            let tbxid = content.subject.transaction_id;
            let ip = content.subject.customer.ip;
            let userid = content.subject.customer.username.id;
            let wkey = crypto.randomBytes(24).toString("hex");

            function checkkey() {
                sql.query(`SELECT * FROM tbxkeys WHERE wkey = ? OR tbxid = ?`, [wkey, tbxid], function (err, data) {
                    if (err) return res.send({});
                    if (data.length !== 0) {
                        if (data[0].wkey === wkey) {
                            wkey = crypto.randomBytes(24).toString("hex");
                            checkkey()
                        } else res.send({});
                    } else {
                        sql.query('INSERT INTO tbxkeys SET ?', {
                            tbxid: tbxid,
                            wkey: wkey,
                            ip: ip,
                            whitelist: true,
                            userid: userid
                        }, function (err) {
                            if (err) return res.send({}); else client.channels.cache.get('933071643637612554').send(
                                '``' + content.subject.customer.username.username + '`` Whitelisted.\n'
                                + 'Ip: ``' + ip + '``\n'
                                + 'TbxID: ``' + tbxid + '``\n'
                                + 'UserID: ``' + userid + '``'
                            ), res.send({});
                        });
                    }
                });
            }
            checkkey()
        }
    },
    login: function (req, res) {
        if (fromTebex(req)) return;
        let uuid = ((req.url || '').toString().split('=').pop().trim()) || ''

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
    }
}
server.post('/execute', function (req, res) {
    expressCommands.blacklistCheck(req, res);
});
server.post('/transaction', function (req, res) {
    expressCommands.transaction(req, res);
});
server.get('/login', function (req, res) {
    expressCommands.login(req, res);
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

        sql.query(args.join(' '), function (err, result) {
            if (err) {
                msg.reply(err.toString())
            } else if (result.length > 0) {
                msg.reply(JSON.stringify(result[0], null, ' '))
            } else {
                msg.reply('executed.')
            }
        });
    }
}
client.on("ready", () => {
    client.user.setActivity(`for sure`, { type: "LISTENING" });
    dServer = client.guilds.cache.get('933052164992020481');
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