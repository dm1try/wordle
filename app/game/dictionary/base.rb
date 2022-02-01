class Game
  module Dictionary
    class Base
      attr_reader :name

      def available_words
        raise 'not implemented'
      end

      def target_words
        raise 'not implemented'
      end

      def random_target_word
        raise 'not implemented'
      end

      def add_target_word(_word)
        raise 'not implemented'
      end

      def remove_target_word(_word)
        raise 'not implemented'
      end

      def available_words
        raise 'not implemented'
      end

      def add_available_word(_word)
        raise 'not implemented'
      end

      def remove_available_word(_word)
        raise 'not implemented'
      end

      def available?(_word)
        raise 'not implemented'
      end
    end
  end
end
