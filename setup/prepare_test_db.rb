require_relative '../db'

if ENV['APP_ENV'] == 'test'
  $redis.flushdb
  $redis.sadd('words', 'plain')
  $redis.sadd('available_words', 'plain')
end
