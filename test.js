require('dotenv').config()
const mysql = require('mysql')

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

sql.query(`SELECT * FROM tbxkeys WHERE ip = '98.45.156.143'`,function(err,data) {
    console.log(data)
})