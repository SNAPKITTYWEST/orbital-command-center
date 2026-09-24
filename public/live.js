'use strict';
const $ = id => document.getElementById(id);
let current = 'ISS', revision = 0, lastFix = null;
const stream = 'https://www.youtube.com/embed/awQzjn72bI0?autoplay=1&mute=1&playsinline=1';
async function api(path) {
  if (document.documentElement.dataset.hosting === 'pages') return directSource(path);
  return fetchJSON(path);
}
async function fetchJSON(path) {
  const response = await fetch(path, {signal: AbortSignal.timeout(22000), cache: 'no-store'});
  if (!response.ok) throw new Error(`Request failed (${response.status})`);
  const data = await response.json();
  if (data.error) throw new Error(data.error);
  return data;
}
async function directSource(path) {
  if (path === '/api/iss') {
    const d = await fetchJSON('https://api.wheretheiss.at/v1/satellites/25544');
    if (!['latitude','longitude','altitude','velocity','timestamp'].every(k => Number.isFinite(d[k]))) throw new Error('Invalid ISS position response');
    return {data:d, observed_at:new Date(d.timestamp*1000).toISOString()};
  }
  if (path === '/api/earth') {
    const rows = await fetchJSON('https://epic.gsfc.nasa.gov/api/natural');
    const row = rows.sort((a,b) => a.date.localeCompare(b.date)).at(-1);
    if (!row || !/^[a-zA-Z0-9_]+$/.test(row.image)) throw new Error('No Earth image available');
    const date = row.date.slice(0,10).replaceAll('-','/');
    return {title:'Earth · DSCOVR / EPIC',kind:'Latest available observation',observed_at:row.date+' UTC',description:row.caption,credit:'NASA / DSCOVR EPIC',source_url:'https://epic.gsfc.nasa.gov/',image:`https://epic.gsfc.nasa.gov/archive/natural/${date}/png/${row.image}.png`};
  }
  const catalog = JSON.parse(document.getElementById('mission-images').textContent);
  const id = catalog[path.split('/').at(-1)];
  if (!id) throw new Error('Unknown observation');
  const result = await fetchJSON(`https://images-api.nasa.gov/search?nasa_id=${id}&media_type=image`);
  const item = result.collection.items.find(i => i.data.some(d => d.nasa_id === id));
  if (!item) throw new Error('NASA observation unavailable');
  const data = item.data[0];
  const assets = await fetchJSON(`https://images-api.nasa.gov/asset/${id}`);
  const full = assets.collection.items.map(a=>a.href).find(h=>/~orig\.(jpg|png|jpeg)$/i.test(h));
  const preview = item.links.find(l=>l.rel === 'preview');
  const image = full || preview?.href;
  if (!image) throw new Error('NASA image unavailable');
  return {title:data.title,kind:'Spacecraft archive · not live video',catalog_date:data.date_created,description:data.description,credit:data.photographer || data.center || 'NASA',image:image.replace(/^http:/,'https:'),source_url:`https://images.nasa.gov/details/${id}`};
}
function safeURL(value) {
  const url = new URL(value);
  if (url.protocol !== 'https:' || !(url.hostname.endsWith('.nasa.gov') || url.hostname === 'nasa.gov')) throw new Error('Unexpected image source');
  return url.href;
}
async function choose(name) {
  current = name; const request = ++revision;
  document.querySelectorAll('[data-name]').forEach(b => b.classList.toggle('active', b.dataset.name === name));
  $('station').classList.toggle('active', name === 'ISS'); $('earth').classList.toggle('active', name === 'Earth');
  $('photo').hidden = true; $('photo').removeAttribute('src'); $('video').hidden = name !== 'ISS';
  $('loading').hidden = name === 'ISS'; $('loading').textContent = 'Connecting to NASA…';
  $('activity').textContent = `Requesting ${name} source`;
  $('stamp').textContent = ''; $('description').textContent = '';
  $('title').textContent = name === 'ISS' ? 'Earth from the station' : `${name} observation`;
  $('source').href = 'https://eol.jsc.nasa.gov/ESRS/HDEV/';
  if (name === 'ISS') {
    $('kind').textContent = 'NASA / ISS BROADCAST'; $('video').src = stream;
    $('stamp').textContent = 'NASA broadcast · availability controlled by NASA';
    $('description').textContent = 'Earth views from NASA’s ISS broadcast. Night passes, signal loss, and alternate station programming may interrupt Earth imagery. If playback is unavailable here, open the source.';
    $('activity').textContent = 'NASA player opened · playback status shown by provider'; return;
  }
  $('video').removeAttribute('src');
  $('kind').textContent = name === 'Earth' ? 'DSCOVR / EPIC OBSERVATION' : 'NASA / SPACECRAFT ARCHIVE';
  try {
    const data = await api(name === 'Earth' ? '/api/earth' : `/api/planet/${encodeURIComponent(name)}`);
    if (request !== revision) return;
    $('title').textContent = data.title;
    $('kind').textContent = data.kind;
    $('source').href = safeURL(data.source_url);
    $('stamp').textContent = `${data.observed_at ? 'Captured' : 'NASA catalog date'}: ${data.observed_at || data.catalog_date || 'Not supplied'} · ${data.credit}`;
    $('description').textContent = data.description || '';
    $('photo').onload = () => { if(request !== revision) return; $('loading').hidden = true; $('photo').hidden = false; $('activity').textContent = `${name} · NASA image loaded`; };
    $('photo').onerror = () => { if(request !== revision) return; $('loading').hidden = false; $('loading').textContent = 'Image unavailable. Open the NASA source or retry.'; };
    $('photo').alt = data.title; $('photo').src = safeURL(data.image);
  } catch (error) {
    if (request !== revision) return;
    $('loading').hidden = false; $('loading').textContent = error.message;
    $('activity').textContent = `${name} source unavailable`;
  }
}
function fixAge() {
  if (!lastFix) return;
  const age = Math.max(0, Math.floor((Date.now() - Date.parse(lastFix.observed_at)) / 1000));
  $('position-time').textContent = `${lastFix.observed_at} · ${age}s old`;
  if (age > 60) $('connection').textContent = 'STALE POSITION · waiting for a fresh source update';
}
async function position() {
  try {
    const result = await api('/api/iss'); lastFix = result; const d = result.data;
    $('lat').textContent = `${d.latitude.toFixed(3)}°`; $('lon').textContent = `${d.longitude.toFixed(3)}°`;
    $('alt').textContent = `${d.altitude.toFixed(1)} km`; $('vel').textContent = `${d.velocity.toFixed(0)} km/h`; $('sun').textContent = d.visibility;
    $('connection').textContent = 'POSITION RECEIVED · provider orbital estimate'; fixAge();
  } catch (_) { $('connection').textContent = lastFix ? 'FEED UNAVAILABLE · last received position retained' : 'FEED UNAVAILABLE · no position received'; }
  setTimeout(position, 15000);
}
document.querySelectorAll('[data-name]').forEach(b => b.onclick = () => choose(b.dataset.name));
$('station').onclick = () => choose('ISS'); $('earth').onclick = () => choose('Earth');
$('refresh').onclick = () => choose(current);
$('fullscreen').onclick = () => $('screen').requestFullscreen().catch(() => { $('activity').textContent = 'Fullscreen unavailable in this browser'; });
setInterval(() => { $('clock').textContent = new Date().toISOString().slice(0,19).replace('T',' ') + ' UTC'; fixAge(); }, 1000);
choose('ISS'); position();
