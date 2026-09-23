# Orbital command center

Ruby 3.4 serves an ERB interface and planet catalog using standard libraries only. Browser Canvas draws the animated 2D scene; plain JavaScript handles controls. No Python, TypeScript, gems, CDN, or external service is required.

Run from this directory:

```powershell
& C:\Ruby34-x64\bin\ruby.exe app.rb
```

Open http://127.0.0.1:9292. Select planets in the directory or canvas. Change simulation speed, pause, toggle layers, zoom, center on a target, highlight its orbit, switch to top-down view, or export a JSON position snapshot.

Validate with `ruby test_app.rb`.

This is a local visualization, not operational spacecraft control. Circular coplanar orbits use approximate periods and arbitrary initial phases; display distances and body sizes are compressed. Coordinates are simulated AU. The MINIKRAN kernel is not connected, and the interface reports that explicitly. The parent project's license applies.
