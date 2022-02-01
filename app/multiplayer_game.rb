require_relative './game'
require 'securerandom'

class MultiplayerGame
  Player = Struct.new(:id, :name)

  attr_reader :start_time, :end_time, :players, :dictionary, :winner

  def initialize(dictionary)
    @dictionary = dictionary
    @players = []
    @games = {}
    @winner = nil
  end

  def add_player(id, name)
    return false if started?
    @players << Player.new(id, name)
  end

  def remove_player(id)
    @players.delete_if { |player| player.id == id }
  end

  def player_exists?(id)
    @players.any? { |player| player.id == id }
  end

  def start
    puts "Game started at #{@start_time}"
    puts "Players: #{@players.join(', ')}"
    puts "Dictionary: #{@dictionary}"

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
end
