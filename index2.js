const express = require('express')
const hwid = express()
hwid.use(express.static(__dirname))
hwid.get("/hwid", function (req, res) {
    res.send('i have your hwid :blush:')
    console.log(req.headers["syn-fingerprint"])
    console.log(req.headers, req.headers['x-forwarded-for'], req.connection.remoteAddress)
})

hwid.get("/transaction", function (req, res) {
    res.send('i have your ip :blush:')
    console.log(req.headers, req.headers['x-forwarded-for'], req.connection.remoteAddress)
})

hwid.listen(process.env.PORT)