const express = require('express')

const INDEX = '/index.html'
const PORT = process.env.PORT

const server = express()
server.use(express.static(__dirname))

server.get("/name", function(req, res){
    res.send(req.headers["syn-fingerprint"])
})

server.listen(PORT)