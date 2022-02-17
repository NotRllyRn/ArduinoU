const { Image } = require('canvas')

function ping(adress) {
    return new Promise(resolve => {
        const date = new Date().getTime()
        const img = new Image();
        let activated = false
        img.onload = function () {
            if (activated) return;
            activated = true
            resolve(new Date().getTime() - date)
        }
        img.onerror = function () {
            if (activated) return;
            activated = true
            resolve(new Date().getTime() - date)
        }
        img.src = adress
    })
}

for (let i = 0; i < 100; i++) {
    (async () => {
        ping('https://www.toptal.com/').then(ms => {
            console.log(ms)
        })
    })()
}