require_relative 'app'

# Static output uses provider CORS APIs; local Ruby routes remain available.
live = Orbital.response('/').last
live = live.sub('<html lang="en">', '<html lang="en" data-hosting="pages">')
live = live.gsub('"/public/', '"public/').gsub('href="/simulation"', 'href="simulation.html"')
catalog = "<script id=\"mission-images\" type=\"application/json\">#{JSON.generate(Feeds::IMAGES)}</script>"
live = live.sub('<script src="public/live.js">', catalog + '<script src="public/live.js">')
File.write(File.join(__dir__, 'index.html'), live)
simulation = Orbital.response('/simulation').last.gsub('"/public/', '"public/')
File.write(File.join(__dir__, 'simulation.html'), simulation)
puts 'Built index.html and simulation.html for GitHub Pages'
