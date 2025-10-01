# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/game'
require_relative '../../app/multiplayer_game'
require_relative '../../app/game/dictionary/test'
require_relative '../../app/game_repository'
require_relative '../../db'

describe GameRepository do
  let(:redis) { $redis }
  let(:repository) { described_class.new(redis) }
  let(:game_id) { 'test_game_123' }

  before do
    redis.flushdb
  end

  after do
    repository.delete(game_id)
  end

  describe 'Game persistence' do
    let(:dictionary) { Game::Dictionary::Test.new(['plain'], ['plain', 'plaia']) }
    let(:game) { Game.new(dictionary, 'plain') }

    it 'saves and loads a game' do
      game.attempt('plaia')
      
      repository.save(game_id, game)
      loaded_game = repository.load(game_id)

      expect(loaded_game).to be_a(Game)
      expect(loaded_game.word).to eq('plain')
      expect(loaded_game.status).to eq(:in_progress)
      expect(loaded_game.attempts.size).to eq(1)
      expect(loaded_game.attempts[0][0]).to eq('plaia')
    end

    it 'returns nil for non-existent game' do
      expect(repository.load('non_existent')).to be_nil
    end

    it 'checks if game exists' do
      expect(repository.exists?(game_id)).to be_falsey
      
      repository.save(game_id, game)
      
      expect(repository.exists?(game_id)).to be_truthy
    end
  end

  describe 'MultiplayerGame persistence' do
    let(:dictionary) { Game::Dictionary::Test.new(['plain'], ['plain', 'plaia']) }
    let(:game) { MultiplayerGame.new(dictionary) }

    it 'saves and loads a multiplayer game' do
      game.add_player('player1', 'Alice')
      game.add_player('player2', 'Bob')
      game.start
      game.attempt('player1', 'plaia')
      
      repository.save(game_id, game)
      loaded_game = repository.load(game_id)

      expect(loaded_game).to be_a(MultiplayerGame)
      expect(loaded_game.players.size).to eq(2)
      expect(loaded_game.players[0].name).to eq('Alice')
      expect(loaded_game.players[1].name).to eq('Bob')
      expect(loaded_game.started?).to be_truthy
      expect(loaded_game.players[0].attempts.size).to eq(1)
    end

    it 'saves and loads ended game with winner' do
      game.add_player('player1', 'Alice')
      game.start
      game.attempt('player1', 'plain')
      
      repository.save(game_id, game)
      loaded_game = repository.load(game_id)

      expect(loaded_game.ended?).to be_truthy
      expect(loaded_game.winner).not_to be_nil
      expect(loaded_game.winner.name).to eq('Alice')
    end
  end
end
