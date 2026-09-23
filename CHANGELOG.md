# Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [Unreleased]

---

## [1.0.0] — 2026-09-23

### Added
- Pure-Ruby HTTP server on port 9292 (`TCPServer`, no gems)
- Eight-planet solar system: Mercury → Neptune with color, AU, period, radius, phase
- ERB template (`view.erb`): heliocentric 2D canvas UI, celestial directory sidebar, telemetry panel, layer toggles, zoom controls, mission status
- Animated canvas (`app.js`): 650 stars, 550 asteroid belt dots, orbit rings, Saturn rings, radial-gradient planets, selection ring, labels
- Controls: pause/resume, simulation speed (1×–50×), zoom (0.5×–3×), focus target, track orbit, top-down view toggle
- Telemetry export: JSON snapshot of all body positions in AU
- Canvas click hit-detection (nearest body within 17px)
- Deterministic LCG RNG (seed 3837) for reproducible star/belt layout
- Mission status panel with kernel connection indicator (offline)
- Minitest suite: 3 tests, 23 assertions covering HTML rendering, JSON catalog, path-traversal protection
- Apache 2.0 license headers on all source files
- User Guide (`docs/USER_GUIDE.md`)
- Technical Guide (`docs/TECHNICAL_GUIDE.md`)
- Contributing guide (`CONTRIBUTING.md`)
- `PORT` environment variable support
