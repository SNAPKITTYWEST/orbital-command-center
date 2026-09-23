# Contributing

Apache 2.0 — contributions are welcome.

## Standards

- **No new dependencies.** The server uses Ruby stdlib only (`socket`, `erb`, `json`, `minitest`). Keep it that way.
- **No Python, TypeScript, npm, bundler, or CDN.** Everything must run with a plain `ruby app.rb`.
- **Tests must pass.** Run `ruby test_app.rb` before opening a pull request. Add a test for any new route or behavior.
- **Headers.** All source files must carry the Apache 2.0 SPDX header.
- **One file per concern.** `app.rb` = server + data. `view.erb` = HTML shell. `app.js` = canvas + controls. `style.css` = styles.

## Pull request checklist

- [ ] `ruby test_app.rb` passes (0 failures, 0 errors)
- [ ] Apache 2.0 header present on any new file
- [ ] `CHANGELOG.md` entry added under `[Unreleased]`
- [ ] No new runtime dependencies introduced
