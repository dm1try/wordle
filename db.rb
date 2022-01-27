require 'polyphony/adapters/redis'

$redis = Redis.new(host: ENV['REDISHOST'] || 'localhost')
