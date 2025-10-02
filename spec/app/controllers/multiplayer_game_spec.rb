require_relative '../../../app/controllers/multiplayer_game'
require_relative '../../../app/multiplayer_game'
require_relative '../../../app/game/dictionary/test'

describe Controllers::MultiplayerGame do
  let(:message) { }
  let(:connection) { double(:connection, write: nil) }
  let(:publisher) { double(:publisher, subscribe: nil, publish: nil) }

  subject { described_class.new(connection, message) }

  before do
    $live_games = {}
    $publisher = publisher
    $game_repository = double(:game_repository, save: nil, load: nil)
  end

  describe '#join' do
    context 'when the game is not found' do
      let(:message) { { 'type' => 'join', 'game_id' => 'not_existed', 'channel' => 'test'} }

      it 'writes an error message' do
        subject.run

        expect(connection).to have_received(:write).with({
          status: 'error',
          type: :join,
          data: {error: :game_not_found, message: 'Game not found'},
          channel: 'test'
        }.to_json)
      end
    end

    context 'when the game is found' do
      let(:message) { { 'type' => 'join', 'game_id' => 'game_id', 'channel' => 'test'} }
      let(:game) { instance_double(MultiplayerGame, add_player: nil, players: [],
                                   started?: false, player_exists?: false, dictionary: double(name: 'en'), host_id: fake_player_id) }
      let(:fake_player_id) { 'fake_uuid' }

      before do
        $live_games['game_id'] = game
      end

      before do
        allow(SecureRandom).to receive(:uuid).and_return(fake_player_id)
      end

      it 'writes a success message' do
        subject.run

        expect(connection).to have_received(:write) do |message|
          json_payload = JSON.parse(message, symbolize_names: true)
          expect(json_payload).to include({status: 'ok',
                                           type: 'join',
                                           data: {player_id: fake_player_id, players: [], dictionary_name: 'en', start_time: nil, host_id: fake_player_id},
                                           channel: 'test'
          })
        end
      end

      context 'when player is already in the game' do
        let(:existing_player_id) { 'existing_player_id' }
        let(:message) { { 'type' => 'join', 'game_id' => 'game_id', 'channel' => 'test', 'player_id' => existing_player_id} }

        before do
          allow(game).to receive(:player_exists?).with(existing_player_id).and_return(true)
        end

        it 'writes a success message' do
          subject.run

          expect(connection).to have_received(:write) do |message|
            json_payload = JSON.parse(message, symbolize_names: true)
            expect(json_payload).to include({status: 'ok',
                                             type: 'join',
                                             data: {player_id: existing_player_id, players: [], dictionary_name: 'en', start_time: nil, host_id: fake_player_id},
                                             channel: 'test'
            })
          end
        end
      end
    end

    context 'when the game alredy started and there are some players in the game' do
      let(:player_id) { 'player_id' }
      let(:player_name) { 'player_name' }
      let(:message) { { 'type' => 'join', 'game_id' => 'game_id', 'channel' => 'test', 'player_id' => player_id} }
      let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new([], [])) }

      before do
        $live_games['game_id'] = game
        game.add_player(player_id, player_name)
        game.start
      end

      it 'writes players data and game start time in the response' do
        subject.run

        expect(connection).to have_received(:write) do |response|
          json_response = JSON.parse(response)
          expect(json_response['data']['players']).to eq([{'id' => player_id, 'name' => player_name,
                                                           'attempts' => []}])
          expect(json_response['data']['start_time']).to be
        end
      end
    end

    context 'when player name is provided' do
      let(:player_name) { 'my_custom_name' }

      let(:message) {
        {
          'type' => 'join', 'game_id' => 'game_id', 'channel' => 'test', 'player_name' => player_name
        }
      }
      let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new([], [])) }

      before do
        $live_games['game_id'] = game
      end

      it 'includes player name in the response' do
        subject.run

        expect(connection).to have_received(:write) do |response|
          json_response = JSON.parse(response)
          expect(json_response['data']['players'].first['name']).to eq(player_name)
        end
      end
    end

    describe '#update_name' do
      let(:player_id) { '1' }
      let(:player_name) { 'name' }
      let(:new_player_name) { 'new_name' }

      let(:message) {
        {
          'type' => 'update_name', 'game_id' => 'game_id', 'channel' => 'test',
          'player_id' => player_id, 'player_name' => new_player_name
        }
      }
      let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new([], [])) }

      before do
        $live_games['game_id'] = game
        game.add_player(player_id, player_name)
      end

      it 'updates a player name' do
        subject.run

        expect(connection).to have_received(:write) do |response|
          json_response = JSON.parse(response)
          expect(json_response['data']['player_name']).to eq(new_player_name)
        end
      end

      context 'with russian letters' do
        let(:new_player_name) { 'имя' }

        it 'updates a player name' do
          subject.run

          expect(connection).to have_received(:write) do |response|
            json_response = JSON.parse(response)
            expect(json_response['data']['player_name']).to eq(new_player_name)
          end
        end
      end

      context 'with invalid name' do
        let(:new_player_name) { 'x' }

        it 'writes an error message' do
          subject.run

          expect(connection).to have_received(:write).with({
            status: 'error',
            type: :update_name,
            data: {error: :invalid_name, message: 'Invalid name'},
            channel: 'test'
          }.to_json)
        end
      end
    end

    describe '#repeat' do
      let(:player_id) { '1' }
      let(:player_name) { 'name' }

      let(:message) {
        {
          'type' => 'repeat', 'game_id' => 'game_id', 'channel' => 'test', 'player_id' => player_id
        }
      }
      let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new(['plain'], ['plain'])) }


      context 'when the game is ended' do
        before do
          $live_games['game_id'] = game
          game.add_player(player_id, player_name)
          game.start
          game.attempt(player_id, 'plain')
        end

        it 'creates a new one and writes it id' do
          subject.run

          expect(connection).to have_received(:write) do |response|
            json_response = JSON.parse(response)
            expect(json_response['data']['game_id']).to match(/\A\w+\z/)
          end
        end
      end
    end

    describe '#start' do
      let(:host_id) { 'host_player_id' }
      let(:non_host_id) { 'other_player_id' }
      let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new(['plain'], ['plain'])) }

      before do
        $live_games['game_id'] = game
        game.add_player(host_id, 'Host Player')
        game.add_player(non_host_id, 'Other Player')
      end

      context 'when the host starts the game' do
        let(:message) {
          {
            'type' => 'start', 'game_id' => 'game_id', 'channel' => 'test',
            'player_id' => host_id
          }
        }

        it 'successfully starts the game' do
          subject.run

          expect(connection).to have_received(:write) do |response|
            json_response = JSON.parse(response)
            expect(json_response['status']).to eq('ok')
            expect(json_response['type']).to eq('start')
            expect(json_response['data']['start_time']).not_to be_nil
          end
        end

        it 'publishes game_started event' do
          subject.run

          expect(publisher).to have_received(:publish).with(
            'game_id',
            :game_started,
            hash_including(:start_time)
          )
        end
      end

      context 'when a non-host player tries to start the game' do
        let(:message) {
          {
            'type' => 'start', 'game_id' => 'game_id', 'channel' => 'test',
            'player_id' => non_host_id
          }
        }

        it 'returns an error' do
          subject.run

          expect(connection).to have_received(:write).with({
            status: 'error',
            type: :start,
            data: {error: :only_host_can_start, message: 'Only host can start'},
            channel: 'test'
          }.to_json)
        end

        it 'does not start the game' do
          subject.run

          expect(game.started?).to be false
        end
      end
    end

    describe '#attempt' do
      let(:player_id) { '1' }
      let(:player_name) { 'player1' }

      let(:message) {
        {
          'type' => 'attempt', 'game_id' => 'game_id', 'channel' => 'test',
          'player_id' => player_id, 'word' => 'plain'
        }
      }
      let(:game) { MultiplayerGame.new(Game::Dictionary::Test.new(['plain'], ['plain'])) }

      context 'when player wins' do
        before do
          $live_games['game_id'] = game
          game.add_player(player_id, player_name)
          game.start
        end

        it 'publishes game_ended event with the word' do
          subject.run

          expect(publisher).to have_received(:publish).with(
            'game_id',
            :game_ended,
            hash_including(winner_id: player_id, word: 'plain')
          )
        end
      end
    end
  end
end
