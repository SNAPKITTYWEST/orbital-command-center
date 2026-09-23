# Technical Guide — Orbital Command Center

## Architecture

```
Browser                          Ruby process (app.rb)
─────────────────────────────    ────────────────────────────────
GET /              ────────────→  ERB.new(view.erb).result(binding)
                   ←────────────  200 text/html
GET /app.js        ────────────→  File.read('app.js')
GET /style.css     ────────────→  File.read('style.css')
GET /api/bodies    ────────────→  JSON.generate(BODIES)
Canvas renders ←── /api/bodies JSON embedded in <script id="data">
```

No framework. No Rack. No gems. The server is a raw `TCPServer` loop. Each request spawns a `Thread`.

---

## Server — `app.rb`

### `Orbital::BODIES`

A frozen array of hashes. Each entry:

```ruby
{
  name:   String,   # Display name
  color:  String,   # CSS hex color
  au:     Float,    # Semi-major axis in AU
  period: Float,    # Orbital period in days
  radius: Integer,  # Mean radius in km
  phase:  Float     # Initial angle offset (radians equivalent)
}
```

Body order: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune.

### `Orbital.response(path) → [content_type, body] | nil`

Handles four routes:

| Path | Response |
|------|----------|
| `/` or `/index.html` | ERB-rendered HTML from `view.erb` |
| `/app.js` | Raw JavaScript source |
| `/style.css` | Raw CSS source |
| `/api/bodies` | JSON array of `BODIES` |
| Anything else | `nil` → 404 |

Path traversal is blocked by returning `nil` for any path not in the explicit list. `app.rb` is deliberately not served (`/app.rb` returns 404).

### `Orbital.run(port = 9292)`

Starts a `TCPServer` on `127.0.0.1:port`. Loop:

1. `server.accept` blocks until a connection arrives.
2. Spawns a `Thread` for each client.
3. `IO.select` with 3-second timeout avoids hanging on incomplete requests.
4. Reads the first line (method + path).
5. Calls `response(path)`.
6. Writes HTTP/1.1 response with `Content-Length` and `Connection: close`.
7. Rescues `IOError` / `SystemCallError` (browser closes early).
8. Always closes the socket in `ensure`.

Response headers sent:
```
Content-Type: <type>
Content-Length: <bytesize>
Connection: close
X-Content-Type-Options: nosniff
```

`PORT` environment variable overrides the default port.

---

## Template — `view.erb`

Single-file ERB template. The BODIES array is serialized into a `<script id="data" type="application/json">` tag, which `app.js` reads with `document.querySelector('#data').textContent`. This avoids an extra HTTP round-trip for the planet catalog.

The template uses `<% BODIES.each do |body| %>` to generate the celestial directory buttons in the left panel. Each button carries a `data-name` attribute matching `body[:name]`.

---

## Renderer — `app.js`

### Data loading

```js
const bodies = JSON.parse(document.querySelector('#data').textContent);
```

### Simulation state

| Variable | Type | Description |
|----------|------|-------------|
| `days` | float | Elapsed simulation time |
| `paused` | bool | Whether animation is frozen |
| `speed` | number | Days per real second |
| `zoom` | float | Camera scale (0.5–3.0) |
| `tilt` | float | Y-axis compression (0.57 = perspective, 1.0 = top-down) |
| `selected` | object | Currently selected body |
| `track` | bool | Whether selected orbit is highlighted |
| `focus` | bool | Whether camera follows selected body |

### RNG

A deterministic LCG with seed `3837` generates star positions and asteroid belt points. This makes the scene layout reproducible across reloads.

```js
let seed = 3837;
const random = () => {
  seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
  return seed / 4294967296;
};
```

### `frame(now)` — main render loop

Called via `requestAnimationFrame`. Each frame:

1. Compute `dt` (capped at 100ms to avoid spiral of death on tab wake).
2. Advance `days += dt * speed` (unless paused).
3. Resize canvas to match CSS size × `devicePixelRatio`.
4. Clear and draw:
   - Stars (650 dots, random positions + alpha)
   - Grid (45px spacing, if layer enabled)
   - Asteroid belt (550 dots between Mars and Jupiter orbits, if enabled)
   - Sun (radial gradient glow + core disc)
   - For each body:
     - Orbit ellipse (if Orbits layer, or if tracking selected)
     - Saturn rings (ellipse at angle 0.4 rad)
     - Planet disc (radial gradient)
     - Selection dashed ring (if selected)
     - Label (if Labels layer)
5. Update coordinate readout and clock.

### Planet sizing

```js
const sizes = [4, 7, 8, 6, 16, 13, 10, 10]; // px at zoom=1
let size = sizes[i] * Math.sqrt(zoom);
```

Saturn's ring is drawn as an ellipse: `rx = size * 1.9`, `ry = size * 0.6`, rotated 0.4 rad.

### Hit detection

`points` is rebuilt every frame with `{x, y, size, body}` for each planet. Canvas click finds the nearest point within `max(size, 17)` pixels.

### Telemetry export

```js
const data = {
  model: 'Idealized circular orbit simulation',
  days,
  bodies: bodies.map(b => {
    let a = b.phase + days / b.period * Math.PI * 2;
    return { name: b.name, x_au: b.au * Math.cos(a), y_au: b.au * Math.sin(a) };
  })
};
```

Uses `URL.createObjectURL` + a synthetic `<a>` click. The blob URL is revoked after 1 second.

---

## Tests — `test_app.rb`

Three `Minitest::Test` cases covering:

| Test | What it checks |
|------|---------------|
| `test_rendered_directory_matches_catalog` | HTTP 200 HTML, all 8 `data-name` attributes present, no unrendered ERB tags |
| `test_catalog_is_valid_json` | `/api/bodies` returns parseable JSON with exactly 8 entries |
| `test_no_arbitrary_file_access` | Path traversal attempts (`/../Cargo.toml`, `/app.rb`) return `nil` (404) |

Run: `ruby test_app.rb`

---

## Extending

### Adding a body

In `app.rb`, add a row to `BODIES`:

```ruby
['Pluto', '#c4a882', 39.48, 90560, 1188, 1.8],
```

The ERB template and canvas renderer pick it up automatically. Adjust the `sizes` array in `app.js` to add a display radius.

### Connecting the MINIKRAN kernel

Add a `/api/kernel` route in `Orbital.response` that calls the Rust FFI or reads from a Unix socket. Update the Mission Status panel in `view.erb` and the `app.js` status poll to reflect live kernel state.

### Serving over a network

Change `TCPServer.new('127.0.0.1', port)` to `TCPServer.new('0.0.0.0', port)`. Add TLS termination via a reverse proxy (nginx, Caddy) before exposing publicly.
