# Live observation frontend

Run `ruby app.rb` and open http://127.0.0.1:9292/.

The default screen embeds the external Earth camera linked by NASA at https://eol.jsc.nasa.gov/ESRS/HDEV/. Playback depends on NASA, YouTube, network access, and the browser. The application does not claim that loading an iframe establishes live playback. Use Open source if embedding is unavailable.

Earth observation retrieves the latest available natural-color image metadata from https://epic.gsfc.nasa.gov/api/natural. The capture timestamp is shown. This observation is from DSCOVR, not the ISS, and is delayed rather than live video.

Other planets retrieve curated mission image identifiers from NASA's Image and Video Library, with original-resolution assets where available. These are archived spacecraft products, which may be processed or composited; catalog dates are explicitly labeled. NASA's original description and source are displayed. There is no live video camera service for these planets in this application.

ISS position is refreshed every 15 seconds from https://api.wheretheiss.at/v1/satellites/25544, with a ten-second backend cache. These are provider orbital estimates, not onboard telemetry or a reconstruction of the camera footprint. Source timestamps older than 60 seconds are flagged stale. Failures show an unavailable state, never generated substitute data. A failed position refresh retains only the previously received, timestamped position.

The previous simulation remains explicitly separate at `/simulation` locally and `simulation.html` on Pages. The kernel is not connected. External media loads directly from NASA or YouTube; the Ruby server proxies only fixed metadata endpoints with HTTPS certificate verification and timeouts.

Run `ruby build_pages.rb` to generate the static Pages entry points from the Ruby templates. On Pages, the frontend calls NASA and ISS public CORS endpoints directly. There is no Ruby server on GitHub Pages and no embedded API key. Source errors remain visible. The existing Pages configuration publishes the repository root from `master`.

Checks: `ruby test/test_app.rb` and `node --check public/live.js`.
