const express = require('express')
const hwid = express()
hwid.use(express.static(__dirname))
hwid.get("/hwid", function (req, res) {
    res.send('i have your hwid :blush:')
    console.log(req.headers["syn-fingerprint"])
    console.log(req.headers['x-forwarded-for'])
})

hwid.get("/transaction", function (req, res) {
    console.log(req)
    res.send({
        "id": "0a494da9d047f1605830c55dba17d9a0`"
    })
})

hwid.listen(process.env.PORT)