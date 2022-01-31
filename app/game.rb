class Game
  STATUSES = [:in_progress, :won, :lost]

  LETTER_IN_CORRECT_POSITION = 2
  LETTER_IN_WRONG_POSITION = 1

  attr_reader :word, :attempts, :status

  def initialize(dictionary, word = nil)
    @dictionary = dictionary
    @attempts = []
    @status = :in_progress
    @word = word || @dictionary.random_target_word
  end

  def word_available?(word)
    @dictionary.available?(word)
  end

  def attempt(word)
    raise ArgumentError, 'word must have 5 letters' unless word.size == 5
    return if @status == :won || @status == :lost

    comparasion_result =
      if word == @word
        @status = :won
        [LETTER_IN_CORRECT_POSITION, LETTER_IN_CORRECT_POSITION, LETTER_IN_CORRECT_POSITION,
         LETTER_IN_CORRECT_POSITION, LETTER_IN_CORRECT_POSITION]
      else
        compare_word(word)
      end

    @attempts << [word, comparasion_result]

    if @attempts.size == 6 && @status == :in_progress
      @status = :lost
    end

    comparasion_result
  end

  def compare_word(word)
    result = [0, 0, 0, 0, 0]
    possible_partial_matches = []
    not_matched_positions = []

    for i in 0...5
      if word[i] == @word[i]
        result[i] = LETTER_IN_CORRECT_POSITION
      else
        possible_partial_matches << @word[i]
        not_matched_positions << i
      end
    end

    not_matched_positions.each do |position|
      if index = possible_partial_matches.index(word[position])
        result[position] = LETTER_IN_WRONG_POSITION
        possible_partial_matches.delete_at(index)
      end
    end

    result
  end

  def last_match
    @attempts.last[1]
  end
end

