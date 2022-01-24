require('dotenv').config()
const crypto = require("crypto");
const mysql = require('mysql')
const express = require('express')
const { Client } = require('discord.js');
const { connect } = require('http2');
const client = new Client({
    intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES'],
    partials: ['MESSAGE', 'CHANNEL']
})

function getIp(req) {
    let ip = (req.headers['x-forwarded-for'] || '').split(',').pop().trim();
    return ip
}
function sendChannel(id, msg) {
    client.channels.fetch(id).send(msg)
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
server.get('/hwid', function (req, res) {
    res.send('i have your hwid :blush:')
    let ip = getIp(req)
    console.log(req.headers['syn-fingerprint'])
    console.log(req.headers['x-forwarded-for'])
    console.log(ip)
});
server.post('/transaction', function (req, res) {
    let content = req.body

    if (!({ '18.209.80.3': true, '54.87.231.232': true }[getIp(req)])) return;
    if (content.type === 'validation.webhook') return res.send({ id: content.id });

    if ((content.type === 'payment.completed') && (content.subject.status.description === 'Complete')) {
        let tbxid = content.subject.transaction_id;
        let ip = content.subject.customer.ip;
        let userid = content.subject.customer.username.id;
        let wkey = crypto.randomBytes(24).toString("hex");

        sql.query(`SELECT * FROM tbxkeys WHERE tbxid = ${tbxid}`, function (err, data) {
            if (err) return;
            if (data.length !== 0) return;

            function checkkey() {
                sql.query(`SELECT * FROM tbxkeys WHERE wkey = ${wkey}`, function (err, data) {
                    if (err) return;
                    if (data.length !== 0) {
                        wkey = crypto.randomBytes(24).toString("hex");
                        checkkey();
                    } else {
                        sql.query('INSERT INTO tbxkeys SET ?', {
                            tbxid: tbxid,
                            wkey: wkey,
                            ip: ip,
                            whitelist: true,
                            userid: userid
                        }, function (err) {
                            if (err) return; else client.channels.cache.get('933071643637612554').send(
                                '``' + content.subject.customer.username.username + '`` Whitelisted.\n'
                                + 'Ip: ``' + ip + '``\n'
                                + 'TbxID: ``' + tbxid + '``\n'
                                + 'UserID: ``' + userid + '``'
                            );
                        });
                    }
                });
            }
        });
    }
});
server.get('/login', function (req, res) {
    if (!({ '18.209.80.3': true, '54.87.231.232': true }[getIp(req)])) return;
    let uuid = (req.url).toString().split('=').pop().trim();
    console.log(uuid)

    if (client.guilds.cache.get('933052164992020481').members.cache.find('422587947972427777')) {
        console.log('found')
        res.send({
            "verified": true
        });
    } else {
        res.send({
            "verified": false,
            "message": 'join the discord server: https://discord.gg/DC3x6V8TpP'
        });
        console.log('not found')
    }
});
server.listen(process.env.PORT);

client.on("ready", () => {
    client.user.setActivity(`for sure`, { type: "LISTENING" });
});
client.login(process.env.DISCORD_TOKEN)