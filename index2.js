const express = require('express')
const server = express()

function getIp (req) {
    let ip = (req.headers['x-forwarded-for'] || '').split(',').pop().trim()
    return ip
}

server.use(express.static(__dirname))
server.use(express.json())

server.get("/hwid", function (req, res) {
    res.send('i have your hwid :blush:')
    console.log(req.headers["syn-fingerprint"])
    console.log(req.headers['x-forwarded-for'])
    console.log(req.ip)
})

server.post("/transaction", function(req, res) {
    let ip = getIp(req)
    if (!({'18.209.80.3': true, '54.87.231.232': true}[ip])) return;
    if(req.body.type === "validation.webhook") return res.send({id: req.body.id});
})

server.listen(process.env.PORT)