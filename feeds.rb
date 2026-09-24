require 'net/http'
require 'json'
require 'time'

module Feeds
  class Unavailable < StandardError; end
  @cache = {}
  @lock = Mutex.new
  # Curated mission-image identifiers: no generative or artist-concept search.
  IMAGES = {'Mercury'=>'PIA15162', 'Venus'=>'PIA00072', 'Mars'=>'PIA00407',
            'Jupiter'=>'PIA22946', 'Saturn'=>'PIA11141', 'Uranus'=>'PIA18182', 'Neptune'=>'PIA01492'}.freeze

  def self.get(url)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 6, read_timeout: 10) do |http|
      http.get(uri.request_uri, {'User-Agent'=>'OrbitalCommandCenter/1.0', 'Accept'=>'application/json'})
    end
    raise Unavailable, "Source returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end

  def self.cached(key, ttl)
    @lock.synchronize do
      entry = @cache[key]
      return entry[:data] if entry && Time.now.to_f - entry[:at] < ttl
    end
    data = yield
    data[:fetched_at] = Time.now.utc.iso8601
    @lock.synchronize { @cache[key] = {at: Time.now.to_f, data: data} }
    data
  rescue StandardError => e
    {error: "Source unavailable (#{e.class.name.split('::').last}). Retry or open the source directly.", fetched_at: Time.now.utc.iso8601}
  end

  def self.iss
    cached('iss', 10) do
      data = get('https://api.wheretheiss.at/v1/satellites/25544')
      %w[latitude longitude altitude velocity timestamp].each { |k| raise Unavailable unless data[k].is_a?(Numeric) && data[k].finite? }
      raise Unavailable unless (-90..90).cover?(data['latitude']) && (-180..180).cover?(data['longitude'])
      {source: 'Where the ISS at? · orbital position estimate', source_url: 'https://wheretheiss.at/',
       observed_at: Time.at(data['timestamp']).utc.iso8601, data: data}
    end
  end

  def self.earth
    cached('earth', 300) do
      items = get('https://epic.gsfc.nasa.gov/api/natural')
      item = items.max_by { |i| i.fetch('date') }
      raise Unavailable unless item && item['image'].match?(/\A[a-zA-Z0-9_]+\z/)
      date = Time.parse(item.fetch('date') + ' UTC')
      {title: 'Earth · DSCOVR / EPIC', kind: 'Latest available observation',
       observed_at: date.iso8601, description: item['caption'],
       image: "https://epic.gsfc.nasa.gov/archive/natural/#{date.strftime('%Y/%m/%d')}/png/#{item['image']}.png",
       source_url: 'https://epic.gsfc.nasa.gov/', credit: 'NASA / DSCOVR EPIC'}
    end
  end

  def self.planet(name)
    cached(name, 3600) do
      id = IMAGES.fetch(name)
      results = get("https://images-api.nasa.gov/search?nasa_id=#{id}&media_type=image").fetch('collection').fetch('items')
      item = results.find { |i| i.fetch('data').any? { |d| d['nasa_id'] == id } }
      raise Unavailable unless item
      data = item.fetch('data').first
      link = item.fetch('links').find { |l| l['rel'] == 'preview' }
      raise Unavailable unless link && URI(link['href']).host == 'images-assets.nasa.gov'
      assets = get("https://images-api.nasa.gov/asset/#{id}").fetch('collection').fetch('items')
      full = assets.map { |a| a['href'] }.compact.find { |href| href.match?(/~orig\.(jpg|png|jpeg)\z/i) && URI(href).host == 'images-assets.nasa.gov' }
      {title: data['title'], kind: 'Spacecraft archive · not live video',
       catalog_date: data['date_created'], description: data['description'],
       image: (full || link['href']).sub('http:', 'https:'), credit: data['photographer'] || data['center'] || 'NASA',
       source_url: "https://images.nasa.gov/details/#{id}"}
    end
  end
end
