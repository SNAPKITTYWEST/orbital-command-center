require 'minitest/autorun'
require_relative 'app'
class OrbitalTest < Minitest::Test
  def test_rendered_directory_matches_catalog
    type, html = Orbital.response('/')
    assert_includes type, 'text/html'
    Orbital::BODIES.each { |b| assert_includes html, "data-name=\"#{b[:name]}\"" }
    refute_includes html, '<%'
  end
  def test_catalog_is_valid_json
    _, json = Orbital.response('/api/bodies')
    assert_equal 8, JSON.parse(json).length
  end
  def test_no_arbitrary_file_access
    assert_nil Orbital.response('/../Cargo.toml')
    assert_nil Orbital.response('/app.rb')
  end
end
