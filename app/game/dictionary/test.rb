require_relative 'base'

class Game
  module Dictionary
    class Test < Base
      def initialize(target_words, available_words)
        @target_words = target_words
        @available_words = available_words
      end

      def target_words
        @target_words
      end

      def add_target_word(word)
        @target_words << word
      end

      def remove_target_word(word)
        @target_words.delete(word)
      end

      def random_target_word
        @target_words.sample
      end

      def available_words
        @available_words
      end

      def add_available_word(word)
        @available_words << word
      end

      def remove_available_word(word)
        @available_words.delete(word)
      end

      def available?(word)
        @available_words.include?(word)
      end
    end
  end
end
