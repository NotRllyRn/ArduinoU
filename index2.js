const express = require('express')
const hwid = express()
hwid.use(express.static(__dirname))
hwid.get("/hwid", function(req, res){
    res.send('i have your hwid :blush:')
    console.log(req.headers["syn-fingerprint"])
    const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
    console.log(ip); // ip address of the user
})
hwid.listen(process.env.PORT)

const whitelist = express()
whitelist.use(express.static(__dirname))
whitelist.get("/transaction", function(req, res){
    res.send('i have your ip :blush:')
    const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log(ip); // ip address of the user
})