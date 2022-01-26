require('dotenv').config()
const crypto = require("crypto");
const mysql = require('mysql')
const express = require('express')
const { Client } = require('discord.js')
const client = new Client({
    intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES'],
    partials: ['MESSAGE', 'CHANNEL']
})

let dServer;

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
    console.log('connected')
});

const server = express()
server.use(express.static(__dirname + "/site"));
server.use(express.json());
server.post('/execute', function (req, res) {
    let content = req.body;
    let ip = getIp(req);
    let hwid = req.headers['syn-fingerprint'];

    if (!content || !ip || !hwid || !content.wkey) return res.send({ w: false, m: "Invalid key." });
    let wkey = content.wkey;

    sql.query('SELECT * FROM tbxkeys WHERE wkey = ?', [wkey], function (err, data) {
        if (err) return;
        if (data.length !== 1) return res.send({ w: false, m: "Invalid key." });

        if (data[0].ip === ip) {
            if (!data[0].hwid) {
                sql.query('UPDATE tbxkeys SET ? WHERE wkey = ?', [
                    {
                        hwid: hwid
                    },
                    wkey
                ], function (err) {
                    if (err) return;
                })
                res.send({
                    w: true,
                    m: ''
                })
                client.channels.cache.get('933054025040031774').send('Script executed by ``' + data[0].userid + '``.')
            } else if (data[0].hwid === hwid) {
                res.send({
                    w: true,
                    m: ''
                })
                client.channels.cache.get('933054025040031774').send('Script executed by ``' + data[0].userid + '``.')
            } else {
                res.send({
                    w: false,
                    m: 'Detected hwid change.'
                })
                client.channels.cache.get('933071691184230400').send('Detected Change; ``' + data[0].userid + '``\n' +
                    data[0].ip + ' < ' + ip + '``\n' + data[0].hwid + ' < ' + hwid + '``'
                );
            }
        } else {
            res.send({
                w: false,
                m: "Detected IP change."
            });
            client.channels.cache.get('933071691184230400').send('Detected Change; ``' + data[0].userid + '``\n' +
                data[0].ip + ' < ' + ip + '``\n' + data[0].hwid + ' < ' + hwid + '``'
            );
        }
    })
});
server.post('/transaction', function (req, res) {
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
});
server.get('/login', function (req, res) {
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
});
server.listen(process.env.PORT);

client.on("ready", () => {
    client.user.setActivity(`for sure`, { type: "LISTENING" });
    dServer = client.guilds.cache.get('933052164992020481');
});
client.login(process.env.DISCORD_TOKEN)