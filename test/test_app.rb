# Copyright 2026 SNAPKITTYWEST
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

require 'minitest/autorun'
require_relative '../app'
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
  def test_landing_page_uses_observation_player
    _, html = Orbital.response('/')
    assert_includes html, 'id="video"'
    refute_includes html, '<canvas'
    assert_includes Orbital.response('/simulation').last, '<canvas'
  end
  def test_failed_source_does_not_manufacture_data
    Feeds.stub(:get, ->(*) { raise IOError, 'offline' }) do
      result = Feeds.planet('Neptune')
      assert result[:error]
      refute result.key?(:image)
      refute result.key?(:data)
    end
  end
  def test_only_known_planets_are_routable
    assert_nil Orbital.response('/api/planet/Pluto')
    assert_nil Orbital.response('/api/planet/https://example.com')
  end
end
