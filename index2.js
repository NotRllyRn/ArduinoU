require('dotenv').config()
const mysql = require('mysql')
const express = require('express')
const { Client } = require('discord.js')
const client = new Client({
    intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES'],
    partials: ['MESSAGE', 'CHANNEL']
})

function getIp(req) {
    let ip = (req.headers['x-forwarded-for'] || '').split(',').pop().trim();
    return ip
}

let sql = mysql.createConnection({
    host: process.env.DBURL,
    user: process.env.DBUSER,
    password: process.env.DBPASS,
    port: 3306,
    database: "main"
})

.connect(function (err) {
    if (err) throw err;
    console.log('connected')
});
const server = express()
server.use(express.static(__dirname));
server.use(express.json());

server.get("/hwid", function (req, res) {
    res.send('i have your hwid :blush:')
    let ip = getIp(req)
    console.log(req.headers["syn-fingerprint"])
    console.log(req.headers['x-forwarded-for'])
    console.log(ip)
});

server.post("/transaction", function (req, res) {
    if (!({ '18.209.80.3': true, '54.87.231.232': true }[getIp(req)])) return;
    let content = req.body
    if (content.type === "validation.webhook") return res.send({ id: content.id });
    if ((content.type === 'payment.completed') && (content.subject.status.description === 'Complete')) {
        let tbxid = content.subject.transaction_id
        let ip = content.subject.customer.ip
        console.log(content.subject.customer.username)
    }
});

server.listen(process.env.PORT);