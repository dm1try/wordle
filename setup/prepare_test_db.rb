require_relative '../db'

if ENV['APP_ENV'] == 'test'
  $redis.flushdb
  $redis.sadd?('words_en', 'plain')
  $redis.sadd?('available_words_en', 'plain')
end
