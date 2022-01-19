require('dotenv').config()
const mysql = require('mysql')
const Sellix = require('sellix-api-wrapper')
const express = require('express')
const { Client } = require('discord.js')
const API = new Sellix.API('ZixQuiL6UYDjYYnUMCXvA44reEo4CNFIeV23xXde9UyY08u4eZqI2TCRkAzseXGF')
const client = new Client({ intents: ['GUILDS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES'], partials: ['MESSAGE', 'CHANNEL'] })

const users_1 = {
    "422587947972427777": true
}

const prefix = ">"
const orderid = "61da9afaec2d4"
const INDEX = '/index.html'
const PORT = process.env.PORT

function checkOrder(orderID, itemID) {
    return API.getOrder(orderID).then(function (result) {
        if (result.data && (result.data.order.product.uniqid === itemID)) {
            return {
                status: result.data.order.status,
                product: result.data.order.product.uniqid,
                code: 2,
            }
        } else {
            return { error: result.error, code: 3, }
        }
    });
}

const server = express()
    .use((req, res) => res.sendFile(INDEX, { root: __dirname }))
    .listen(PORT)
const { Server } = require('ws')
const wss = new Server({ server })

let con = mysql.createConnection({
    host: process.env.DBURL,
    user: process.env.DBUSER,
    password: process.env.DBPASS,
    port: 3306,
    database: "main"
})

con.connect(function (err) {
    if (err) throw err;
});

client.on("ready", () => {
    client.user.setActivity('>claim', { type: "LISTENING" })
})

let DiscordCommands = {
    ping: function (msg) {
        msg.reply("pong")
    },
    claim: function (msg, args) {
        if (msg.channel.type !== "DM") {
            msg.delete()
            msg.author.send(
                "Please do not share your invoice publicly. " +
                "People may steal your invoice and claim it first. Instead, use the '>claim' command here."
            ).catch(() => {
                msg.channel.send("<@" + msg.author.id + "> Please enable your dm's & use the command there.")
            })
            return
        }
        if (!args) { msg.reply("Invoice required."); return }
        if (args.length < 1) { msg.reply("Invoice required."); return }
        checkOrder(args[0], orderid).then(function (data) {
            if (data.code !== 3) {
                let send = "SELECT * FROM invoices where invoice = '" + args[0] + "'"
                con.query(send, function (err, result) {
                    if (err) { console.log(err); return }
                    if (result.length > 0) {
                        msg.reply("Invoice has already been claimed.")
                    } else {
                        if (data.status === "COMPLETED") {
                            let send = "INSERT INTO invoices SET ?"
                            let data = {
                                invoice: args[0],
                                whitelist: true,
                                did: msg.author.id
                            }
                            con.query(send, data, function (err) {
                                if (err) {
                                    msg.reply("An error occured. DM ``PancakeCat#0715``")
                                    console.log(err)
                                } else {
                                    msg.reply("You have been whitelisted!")
                                    client.channels.cache.get('933071643637612554')
                                        .send('``' + msg.author.tag + '`` has been whitelisted!\nInvoice: ``' + args[0] + '``')
                                }
                            })
                        } else {
                            msg.reply("Order has been canceled or has not been completed.")
                        }
                    }
                });
            } else {
                if (data.error === "Unauthorized.") {
                    data.error = "Invalid Invoice."
                }
                msg.reply(data.error)
            }
        })
    },
    check: function (msg, args) {
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Atleast 2 arguments required.'); return }
        if (args.length < 2) { msg.reply('Atleast 2 arguments required.'); return }
        let send = "SELECT * FROM invoices WHERE " + args[0] + " = '" + args[1] + "'"
        con.query(send, function (err, result) {
            if (err) { console.log(err); return }
            if (result.length === 0) return;
            let data = result[0]
            msg.author.send("Fetched.\n" +
                "Userid: ``" + data.did +
                "``\nInvoice: ``" + data.invoice +
                "``\nHwid: ``" + data.hwid +
                "``\nIp: ``" + data.ip +
                "``\nWhitelisted: ``" + data.whitelist + '``'
            )
        })
    },
    blacklist: function (msg, args) {
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Invoice required.'); return }
        if (args.length < 1) { msg.reply('invoice required.'); return }
        let send = "SELECT * FROM invoices WHERE invoice = '" + args[0] + "'"
        con.query(send, function (err, result) {
            if (err) { console.log(err); return }
            if (result.length !== 1) {
                msg.reply("Couldn't find invoice.")
            } else {
                let send = "UPDATE invoices SET ? WHERE invoice = '" + args[0] + "'"
                let data = { whitelist: false }
                con.query(send, data, function (err) {
                    if (err) {
                        msg.reply("Something went wrong.")
                    } else {
                        msg.reply("User has been blacklisted.")
                    }
                })
            }
        })
    },
    whitelist: function (msg, args) {
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Invoice required.'); return }
        if (args.length < 1) { msg.reply('invoice required.'); return }
        let send = "SELECT * FROM invoices WHERE invoice = '" + args[0] + "'"
        con.query(send, function (err, result) {
            if (err) { console.log(err); return }
            if (result.length !== 1) {
                msg.reply("Couldn't find invoice.")
            } else {
                let send = "UPDATE invoices SET ? WHERE invoice = '" + args[0] + "'"
                let data = { whitelist: true }
                con.query(send, data, function (err) {
                    if (err) {
                        msg.reply("Something went wrong.")
                    } else {
                        msg.reply("User has been whitelisted.")
                    }
                })
            }
        })
    },
    msg: async function (msg, args) {
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Minimum of 2 arguments required.'); return }
        if (args.length < 2) { msg.reply('Minimum of 2 arguments required.'); return }
        let [id, ...msg_1] = [...args]
        const user = await client.users.fetch(id).catch(() => null);
        if (!user) return msg.reply('Unable to find user. Make sure you provide a valid userID')
        await user.send(msg_1.join(" ")).then(() => {
            msg.reply('Message sent successfully.')
        }).catch(() => {
            msg.reply('Unable to message the user. Bot has no mutal servers with the user, or the user has dms closed.')
        });
    },
    pblacklist: function (msg, args) {
        if (msg.channel.type !== "DM") {
            msg.delete()
            msg.author.send(
                "USE CMD HERE. Jeez"
            ).catch(() => {
                msg.channel.send("<@" + msg.author.id + "> Please enable your dm's & use the command there.")
            })
            return
        }
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Minimum of 2 arguments required.'); return }
        if (args.length < 2) { msg.reply('Minimum of 2 arguments required.'); return }
        let [ip, hwid] = [...args]
        let send = "INSERT INTO blacklisted SET ?"
        let data = {
            hwid: hwid,
            ip: ip
        }
        con.query(send, data, function (err) {
            if (err) { console.log(err); msg.reply('An error occured.'); return }
            msg.reply('Ip & Hwid has been permenantly blacklisted.')
        })
    },
    mysql: function (msg, args) {
        if (msg.channel.type !== "DM") {
            msg.delete()
            msg.author.send(
                "USE CMD HERE. Jeez"
            ).catch(() => {
                msg.channel.send("<@" + msg.author.id + "> Please enable your dm's & use the command there.")
            })
            return
        }
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Minimum of 2 arguments required.'); return }
        if (args.length < 2) { msg.reply('Minimum of 2 arguments required.'); return }
        let [use, ...send] = [...args]
        send = send.join(" ")
        if (use.toLowerCase() === "main") {
            con.query(send, function (err, result) {
                let sendback = []
                if (err) {
                    console.log(err)
                    msg.reply("" + err)
                } else if (result.length > 0) {
                    for (var i = 0, tab; tab = result[0][i]; i++) {
                        sendback[i] = tab
                    }
                    msg.reply(sendback.join("\n"))
                } else {
                    msg.reply('No data came back. Success?')
                }
            })
        } else {
            msg.reply("Please provide a valid database.")
        }
    },
    emit: function (msg, args) {
        if (!users_1[msg.author.id.toString().trim()]) { msg.reply('Unauthorized.'); return }
        if (!args) { msg.reply('Message required.'); return }
        if (args.length < 1) { msg.reply('Message required.'); return }
        if (wss.clients.size === 0) { msg.reply('There are no connected clients right now.'); return }
        let message = args.join(" ")
        wss.clients.forEach(function (client1) {
            client1.send('1 ' + message)
        })
        msg.reply('Message sent to ' + wss.clients.size + ' user(s) successfully.')
    },
    active: function (msg, args) {
        msg.reply('There are currently ' + wss.clients.size + ' user(s) using the script.')
    }
}

client.on("messageCreate", msg => {
    if (msg.author.bot) return;
    let content = msg.content
    if (content.startsWith(prefix)) {
        let [name, ...args] = content
            .trim()
            .substring(prefix.length)
            .split(" ");
        let insert = [
            msg,
        ]
        if (args.length > 0) {
            insert.splice(2, 0, args)
        }
        if (DiscordCommands[name]) {
            DiscordCommands[name](...insert)
        }
    }
})

client.login(process.env.TOKEN)

wss.on('connection', (ws) => {
    ws.on('message', async function (msg) {
        let [type, ...msg1] = msg.toString().trim().split(" ")
        if (type === "0") {
            let [invoice, hwid, ip] = [...msg1]
            let send = "SELECT * FROM invoices where invoice = '" + invoice + "'"
            con.query(send, function (err, result) {
                if (err) { console.log(err); return }
                if (result.length > 0) {
                    let hwid_1 = result[0].hwid
                    let ip_1 = result[0].ip
                    if (hwid_1 && ip_1) {
                        if ((hwid_1 === hwid) && (ip_1 === ip) && (result[0].whitelist === 1)) {
                            ws.send("0 t")
                            client.channels.cache.get('933054025040031774')
                                .send('Executed successfully.\nInvoice: ``' + invoice + '``\nIp: ``' + ip + '``\nHwid: ``' + hwid + '``\nDId: ``' + result[0].did + '``');
                        } else if ((hwid_1 === hwid) && (ip_1 === ip)) {
                            ws.send("0 f")
                            client.channels.cache.get('933054025040031774')
                                .send('Whitelist false.\nInvoice: ``' + invoice + '``\nIp: ``' + ip + '``\nHwid: ``' + hwid + '``')
                        } else {
                            ws.send("0 f")
                            client.channels.cache.get('933071691184230400')
                                .send('<@422587947972427777>\n``' + result[0].did + '``; Potitial sharing of key.\nDefault:\n``' + ip_1 + '``\n``' + hwid_1 + '``\nShare:\n``' + ip + '``\n``' + hwid + '``');
                        }
                    } else {
                        console.log(invoice, hwid, ip)
                        let send = "UPDATE invoices SET ? WHERE invoice = '" + invoice + "'"
                        let data = { hwid: hwid, ip: ip }
                        con.query(send, data, function (err) {
                            if (err) { console.log(err); return }
                            ws.send("0 t")
                            client.channels.cache.get('933071643637612554')
                                .send('Executed & claimed.\nInvoice: ``' + invoice + '``\nIp: ``' + ip + '``\nHwid: ``' + hwid + '``\nDId: ``' + result[0].did + '``');
                        })
                    }
                } else {
                    ws.send("0 f")
                }
            });
        }
    })
});