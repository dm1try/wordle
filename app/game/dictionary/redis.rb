require_relative 'base'

class Game
  module Dictionary
    class Redis < Base
      def initialize(redis, target_words_set_name, available_words_set_name)
        @redis = redis
        @target_words_set_name = target_words_set_name
        @available_words_set_name = available_words_set_name
      end

      def target_words
        @redis.smembers(@target_words_set_name)
      end

      def add_target_word(word)
        @redis.sadd(@target_words_set_name, word)
        add_available_word(word)
      end

      def remove_target_word(word)
        @redis.srem(@target_words_set_name, word)
      end

      def random_target_word
        @redis.srandmember(@target_words_set_name)
      end

      def available_words
        @redis.smembers(@available_words_set_name)
      end

      def add_available_word(word)
        @redis.sadd(@available_words_set_name, word)
      end

      def remove_available_word(word)
        @redis.srem(@available_words_set_name, word)
        remove_target_word(word)
      end

      def available?(word)
        @redis.sismember(@available_words_set_name, word)
      end
    end
  end
end
