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

require 'socket'
require 'erb'
require 'json'

module Orbital
  ROOT = __dir__
  BODIES = [
    ['Mercury', '#aba8a3', 0.387, 88, 2440, 0.2],
    ['Venus', '#edbe70', 0.723, 224.7, 6052, 2.6],
    ['Earth', '#40b9ff', 1.0, 365.25, 6371, 0.9],
    ['Mars', '#ee754d', 1.524, 687, 3390, 5.6],
    ['Jupiter', '#dcb08b', 5.203, 4333, 69911, 4.2],
    ['Saturn', '#e5c687', 9.537, 10759, 58232, 5.5],
    ['Uranus', '#78e3e8', 19.191, 30687, 25362, 2.9],
    ['Neptune', '#4779ed', 30.069, 60190, 24622, 3.8]
  ].map { |name, color, au, period, radius, phase| { name: name, color: color, au: au, period: period, radius: radius, phase: phase } }.freeze

  def self.response(path)
    case path
    when '/', '/index.html'
      ['text/html; charset=utf-8', ERB.new(File.read(File.join(ROOT, 'view.erb'))).result(binding)]
    when '/app.js' then ['text/javascript; charset=utf-8', File.read(File.join(ROOT, 'app.js'))]
    when '/style.css' then ['text/css; charset=utf-8', File.read(File.join(ROOT, 'style.css'))]
    when '/api/bodies' then ['application/json', JSON.generate(BODIES)]
    else nil
    end
  end

  def self.run(port = 9292)
    server = TCPServer.new('127.0.0.1', port)
    puts "Orbital command center: http://127.0.0.1:#{port}"
    loop do
      client = server.accept
      Thread.new(client) do |socket|
        begin
          if IO.select([socket], nil, nil, 3)
            method, target = socket.gets(4096).to_s.split
            result = method == 'GET' ? response(target.to_s.split('?').first) : nil
            type, body = result || ['text/plain', 'Not found']
            socket.write "HTTP/1.1 #{result ? '200 OK' : '404 Not Found'}\r\nContent-Type: #{type}\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\nX-Content-Type-Options: nosniff\r\n\r\n"
            socket.write body
          end
        rescue IOError, SystemCallError
          # A browser may close a pending request during navigation.
        ensure
          socket.close
        end
      end
    end
  end
end

Orbital.run(Integer(ENV.fetch('PORT', '9292'))) if $PROGRAM_NAME == __FILE__
