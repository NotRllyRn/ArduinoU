function getHWID(req) {
    const headers = ["Syn-Fingerprint", "Krnl-Hwid"];
    for (let i = 0; i < headers.length; i++) {
        if (req.headers[headers[i]]) {
            return req.headers[headers[i]];
        }
    }
}

console.log(getHWID({
    headers: {
        "Syn-Fingerprint": 'HI'
    }
}));