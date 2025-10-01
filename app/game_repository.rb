# frozen_string_literal: true

require 'json'

class GameRepository
  def initialize(redis)
    @redis = redis
  end

  def save(game_id, game)
    key = game_key(game_id)
    data = serialize(game)
    @redis.set(key, data)
    @redis.expire(key, 86400) # Expire after 24 hours
  end

  def load(game_id)
    key = game_key(game_id)
    data = @redis.get(key)
    return nil unless data

    deserialize(data)
  end

  def exists?(game_id)
    @redis.exists?(game_key(game_id))
  end

  def delete(game_id)
    @redis.del(game_key(game_id))
  end

  private

  def game_key(game_id)
    "game:#{game_id}"
  end

  def serialize(game)
    JSON.generate(game.to_h)
  end

  def deserialize(data)
    hash = JSON.parse(data)
    
    case hash['type']
    when 'Game'
      Game.from_h(hash)
    when 'MultiplayerGame'
      MultiplayerGame.from_h(hash)
    else
      raise "Unknown game type: #{hash['type']}"
    end
  end
end
