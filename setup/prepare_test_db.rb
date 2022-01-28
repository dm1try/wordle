require_relative '../db'

if ENV['APP_ENV'] == 'test'
  $redis.flushdb
  $redis.sadd('words', 'plain')
end
