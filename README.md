# Orbital Command Center

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-3.2%2B-red.svg)](https://www.ruby-lang.org/)
[![Tests](https://img.shields.io/badge/tests-3%20tests%2C%2023%20assertions-brightgreen.svg)]()
[![No gems](https://img.shields.io/badge/dependencies-stdlib%20only-lightgrey.svg)]()

**A zero-dependency Ruby web server and interactive 2D solar system visualization.**

Eight planets animate in real time. Select any body for telemetry. Toggle display layers, zoom, pause, change simulation speed, focus on a target, and export a JSON position snapshot — all in a single browser tab.

---

## Live demo

> **[→ Open in browser](https://snapkittywest.github.io/orbital-command-center/)**

Served via GitHub Pages — no install required.

---

## Run locally

```bash
# Ruby 3.2+ required. No gems. No bundler. No npm.
ruby app.rb

# Custom port
PORT=8080 ruby app.rb
```

Open **http://127.0.0.1:9292** in any modern browser.

```bash
# Run the test suite
ruby test_app.rb
# 3 tests, 23 assertions, 0 failures, 0 errors
```

---

## What it looks like

```
┌─────────────────────────────────────────────────────────────────────┐
│ ◎ ORBITAL VIEW  SOLAR SYSTEM   ORBITAL MAP   TOP DOWN   EXPORT ↗   │
├───────────┬─────────────────────────────────────────┬───────────────┤
│ CELESTIAL │                                         │ SELECTED      │
│ DIRECTORY │   ·  ·  .  *    [animated canvas]  .   │ TARGET        │
│           │                                         │               │
│ ○ Mercury │      *  ·  ·  ☀  ·  ○  ·  ·  *  ·     │  🌍 EARTH     │
│ ○ Venus   │                                         │               │
│ ● Earth   │   orbit rings, asteroid belt, labels    │ Radius 6371km │
│ ○ Mars    │                                         │ Distance 1 AU │
│   ...     │                                         │ Period 365 d  │
│           ├─────────────────────────────────────────┤               │
│ LAYERS    │  T + 42.00 DAYS   HELIOCENTRIC / 2D    │ ⌖ FOCUS       │
│ ☑ Orbits  ├─────────────────────────────────────────┤ ◎ TRACK       │
│ ☑ Labels  │ Ⅱ PAUSE  [speed] + −  X: 0.992  Y: 0.1│               │
└───────────┴─────────────────────────────────────────┴───────────────┘
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [User Guide](docs/USER_GUIDE.md) | Controls, features, export format |
| [Technical Guide](docs/TECHNICAL_GUIDE.md) | Architecture, server, rendering pipeline |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Changelog](CHANGELOG.md) | Release history |

---

## Files

```
orbital-command-center/
├── app.rb          # HTTP server + planet catalog (stdlib only)
├── view.erb        # ERB template — full UI shell
├── app.js          # Canvas renderer + controls
├── style.css       # Mission-control dark theme
├── test_app.rb     # Minitest suite (3 tests, 23 assertions)
├── docs/
│   ├── USER_GUIDE.md
│   └── TECHNICAL_GUIDE.md
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE         # Apache 2.0
```

---

## Notes

- **Local only.** The server binds to `127.0.0.1` — not accessible over a network by default.
- **Simulated data.** Circular coplanar orbits with approximate periods and arbitrary initial phases. Distances and body sizes are visually compressed for display.
- **No kernel connection.** The MINIKRAN orchestration kernel is not wired in. The UI reports this explicitly in the Mission Status panel.

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).  
Copyright 2026 SNAPKITTYWEST.
