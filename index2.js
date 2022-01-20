const express = require('express')
const hwid = express()
hwid.use(express.static(__dirname))
hwid.get("/hwid", function (req, res) {
    res.send('i have your hwid :blush:')
    console.log(req.headers["syn-fingerprint"])
    console.log(req.headers['x-forwarded-for'])
})

hwid.use(express.json())

hwid.post("/transaction", function(req, res) {
    if(req.body.type === "validation.webhook")
        return res.send({id: req.body.id})
})

hwid.listen(process.env.PORT)