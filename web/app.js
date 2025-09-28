const API = "REPLACE_WITH_API_BASE_URL";
const PRESIGN_API_KEY = "REPLACE_WITH_SECRET_KEY";

async function presign(name, type) {
    const r = await fetch(`${API}/presign`, {
        method: 'POST',
        headers: {
            'content-type': 'application/json',
            'x-api-key': PRESIGN_API_KEY
        },
        body: JSON.stringify({ filename: name, contentType: type, prefix: 'sam' })
    });
    if (!r.ok) throw new Error(await r.text()); 
    return r.json();
}

async function upload() {
    const input = document.getElementById('file');
    const f = input.files[0];
    if (!f) return;
    const { url, key} = await presign(f.name, f.type || 'application/octet-stream');
    const put = await fetch(url, {method: 'PUT', headers: {'content-type': f.type || 'application/octet-stream'}, body: f});
    if (!put.ok ) throw new Error ('upload failed');
    document.getElementById('out').textContent = `uploaded: ${key}`;
    input.value = '';
    await list();
}

async function list() {
    const r = await fetch(`${API}/files`); 
    if (!r.ok) return; 
    const items = await r.json();
    const ul= document.getElementById('list')
    ul.innerHTML = '';
    for (const item of items) {
        const li = document.createElement('li');
        li.textContent = `${item.object_Key} - ${its_status} - sha256: ${item.sha256}`;
        ul.appendChild(li);
    }
}


document.getElementById('btn').onclick = () => upload().catch(e => {
    document.getElementById('out').textContent = String(e);
});

list(); 