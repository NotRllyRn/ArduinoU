const crypto = require('crypto')

let hashed = crypto.createHash('sha3-256').update('Niway').digest('hex')

console.log(hashed)