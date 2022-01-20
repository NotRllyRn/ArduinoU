const express = require('express')
const server = express()

server.use(express.static(__dirname))
server.use(express.json())

server.get("/hwid", function (req, res) {
    res.send('i have your hwid :blush:')
    console.log(req.headers["syn-fingerprint"])
    console.log(req.headers['x-forwarded-for'])
    console.log(req.ip)
})

server.post("/transaction", function(req, res) {
    console.log('hello')
    if(req.body.type === "validation.webhook") return res.send({id: req.body.id});
})

server.listen(process.env.PORT)