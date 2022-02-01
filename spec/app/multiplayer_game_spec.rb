require 'spec_helper'
require_relative '../../app/multiplayer_game'
require_relative '../../app/game/dictionary/test'

describe MultiplayerGame do
  let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new(['plain'], ['plain'])) }

  describe '#add_player' do
    it 'adds a player to the game' do
      game.add_player(1, 'player1')
      expect(game.players.size).to eq(1)
    end
  end

  describe '#remove_player' do
    it 'removes a player from the game' do
      game.add_player(1, 'player1')
      game.remove_player(1)
      expect(game.players.size).to eq(0)
    end
  end

  describe '#started?' do
    it 'returns true if the game has started' do
      game.start
      expect(game.started?).to eq(true)
    end

    it 'returns false if the game has not started' do
      expect(game.started?).to eq(false)
    end
  end

  describe '#player_exists?' do
    it 'checks if a player is in a game' do
      game.add_player(1, 'player1')
      expect(game.player_exists?(1)).to eq(true)
    end
  end

  describe '#attempt' do
    it 'returns board game' do
      game.add_player(1, 'player1')
      game.start
      board_game = game.attempt(1, 'plain')
      expect(board_game).to be_instance_of(Game)
      expect(board_game.attempts.first).to eq(["plain", [2,2,2,2,2]])
    end

    context 'when player wins' do
      before do
        game.add_player(1, 'player1')
        game.start
        game.attempt(1, 'plain')
      end

      it 'returns attempts result' do
        expect(game.end_time).to be
      end

      it 'returns the winner name' do
        expect(game.winner_name).to eq('player1')
      end

      it 'returns ended? as true' do
        expect(game.ended?).to eq(true)
      end
    end

    context 'when 2 players and first one already won' do
      before do
        game.add_player(1, 'player1')
        game.add_player(2, 'player2')

        game.start
        game.attempt(1, 'plain')
      end

      it 'does not change a winner' do
        expect(game.winner_name).to eq('player1')
      end
    end
  end
end

