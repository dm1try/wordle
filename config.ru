require 'bundler/setup'
require 'tipi'
require 'tipi/websocket'
require_relative './app'

puts "pid: #{Process.pid}"
puts 'Listening on port 1234...'

run App.new 
