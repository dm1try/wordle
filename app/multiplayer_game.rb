require_relative './game'
require 'securerandom'

class MultiplayerGame
  Player = Struct.new(:id, :name, :attempts)

  attr_reader :start_time, :end_time, :players, :dictionary, :winner

  def initialize(dictionary)
    @dictionary = dictionary
    @players = []
    @games = {}
    @winner = nil
  end

  def add_player(id, name)
    return false if started?
    @players << Player.new(id, name, [])
  end

  def remove_player(id)
    @players.delete_if { |player| player.id == id }
  end

  def player_exists?(id)
    @players.any? { |player| player.id == id }
  end

  def update_player_name(id, name)
    @players.each do |player|
      player.name = name if player.id == id
    end
  end

  def start
    puts "Game started at #{@start_time}"
    puts "Players: #{@players.join(', ')}"
    puts "Dictionary name: #{@dictionary.name}"

    @start_time = Time.now
    target_word = @dictionary.random_target_word
    @players.each do |player|
      @games[player.id] = Game.new(@dictionary, target_word)
    end
  end

  def started?
    @start_time != nil
  end

  def ended?
    @end_time != nil
  end

  def stop
    @end_time = Time.now
  end

  def attempt(player_id, word)
    player = @players.find { |p| p.id == player_id }
    raise "player not found #{player_id}" if player.nil?

    game = @games[player_id]
    raise 'player game not found' if game.nil?

    attempt_result = game.attempt(word)

    player.attempts << attempt_result
    return game if ended?

    if game.status == :won
      puts "#{player.name} won!"
      @winner = player
      stop
    end

    game
  end

  def player_game(player_id)
    @games[player_id]
  end

  def word_available?(word)
    @dictionary.available?(word)
  end

  def winner_name
    @winner.name
  end

  def to_h
    {
      type: 'MultiplayerGame',
      dictionary_name: @dictionary.name,
      players: @players.map { |p| { id: p.id, name: p.name, attempts: p.attempts } },
      games: @games.transform_values { |game| game.to_h },
      start_time: @start_time&.iso8601,
      end_time: @end_time&.iso8601,
      winner_id: @winner&.id
    }
  end

  def self.from_h(hash)
    require_relative './game/dictionary/redis'
    
    dictionary_name = hash['dictionary_name']
    if dictionary_name == 'en'
      dictionary = Game::Dictionary::Redis.new($redis, 'words_en', 'available_words_en', 'en')
    else
      dictionary = Game::Dictionary::Redis.new($redis, 'words', 'available_words', 'ru')
    end
    
    game = new(dictionary)
    
    # Restore players
    hash['players'].each do |player_data|
      player = Player.new(player_data['id'], player_data['name'], player_data['attempts'])
      game.instance_variable_get(:@players) << player
    end
    
    # Restore games
    games = {}
    hash['games'].each do |player_id, game_data|
      games[player_id] = Game.from_h(game_data)
    end
    game.instance_variable_set(:@games, games)
    
    # Restore timestamps
    game.instance_variable_set(:@start_time, hash['start_time'] ? Time.parse(hash['start_time']) : nil)
    game.instance_variable_set(:@end_time, hash['end_time'] ? Time.parse(hash['end_time']) : nil)
    
    # Restore winner
    if hash['winner_id']
      winner = game.instance_variable_get(:@players).find { |p| p.id == hash['winner_id'] }
      game.instance_variable_set(:@winner, winner)
    end
    
    game
  end
end
