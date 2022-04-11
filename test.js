// a function that sleeps for a given amount of time
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


async function validUUID(uuid) {
    if (!uuid) return false;
    return await sleep(5000).then(() => {
        return uuid.toString().trim()
    }).catch(() => {
        return false
    });
}

console.log(await validUUID('a'))