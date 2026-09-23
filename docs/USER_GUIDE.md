# User Guide — Orbital Command Center

## Starting the application

```bash
ruby app.rb
```

Open **http://127.0.0.1:9292** in Chrome, Firefox, Safari, or Edge.

To use a different port:

```bash
PORT=8080 ruby app.rb
```

---

## Interface overview

The screen is divided into three columns and a footer control bar.

### Left — Celestial Directory

Lists all eight planets. Click any name to select that body. The selected body is highlighted in blue and its telemetry appears in the right panel.

**Display Layers** checkboxes below the list toggle:

| Layer | Effect |
|-------|--------|
| **Orbits** | Show or hide the elliptical orbit rings |
| **Labels** | Show or hide planet name labels on the canvas |
| **Asteroid belt** | Show or hide the asteroid belt scatter field |
| **Grid** | Show or hide the background reference grid |

### Centre — Canvas

The animated 2D heliocentric view. The Sun is at the centre. Planets orbit at their approximate distances (visually compressed).

**Clicking a planet** on the canvas selects it.

**Zoom buttons** (top-right of canvas):
- `+` — zoom in (up to 3×)
- `−` — zoom out (down to 0.5×)
- `⌖` — reset zoom and camera

### Right — Target Panel

Shows telemetry for the currently selected body:

| Field | Description |
|-------|-------------|
| **Radius** | Mean radius in kilometres |
| **Mean distance** | Semi-major axis in AU |
| **Orbital period** | Sidereal period in days |
| **Model** | Always "Circular / coplanar" (idealized) |

**FOCUS TARGET** — pans the camera so the selected body stays centred.

**TRACK ORBIT** — highlights the orbit ring of the selected body in bright blue.

**Mission Status** shows the live signal wave and confirms whether the MINIKRAN kernel is connected (it is offline by default).

---

## Footer controls

| Control | Description |
|---------|-------------|
| **Ⅱ PAUSE / ▶ RESUME** | Freeze or resume the simulation |
| **Speed slider** | 1× – 50× simulation speed |
| **SOLAR SYSTEM** nav | Top-down view off (perspective tilt) |
| **TOP DOWN** nav | Switch to flat top-down view |
| **EXPORT TELEMETRY ↗** | Download current positions as JSON |
| **X / Y coordinates** | Live AU coordinates of the selected body |
| **T + N.NN DAYS** | Elapsed simulation days |

---

## Exporting telemetry

Click **EXPORT TELEMETRY ↗** to download `orbital-telemetry.json`. The file contains:

```json
{
  "model": "Idealized circular orbit simulation",
  "days": 1247.83,
  "bodies": [
    { "name": "Mercury", "x_au": 0.187, "y_au": -0.334 },
    { "name": "Venus",   "x_au": -0.621, "y_au": 0.389 },
    ...
  ]
}
```

Coordinates are in AU in the heliocentric plane. These are simulated values from the circular orbit model — not ephemeris data.

---

## Keyboard shortcuts

The application currently uses click/mouse controls only. Keyboard shortcuts are not implemented in this release.

---

## Limitations

- **Eight planets only.** Dwarf planets, moons, and minor bodies are not modelled.
- **Circular orbits.** Actual planetary orbits are elliptical. This visualization uses idealized circles.
- **Compressed distances.** Bodies are spaced linearly by orbital index, not by true AU distance, so the outer planets appear much closer to the inner planets than in reality.
- **No real ephemeris.** Initial phases are arbitrary and do not correspond to any real date.
- **Local server.** Binds to `127.0.0.1` only. Not accessible from other machines on your network.
