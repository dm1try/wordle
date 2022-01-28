require 'bundler/setup'
require 'tipi'
require 'tipi/websocket'
require_relative './db'
require_relative './app'
require_relative './app/game_updates_publisher'

$publisher = GameUpdatesPublisher.new
$publisher.run

puts "pid: #{Process.pid}"
puts 'Listening on port 1234...'

run App.build
