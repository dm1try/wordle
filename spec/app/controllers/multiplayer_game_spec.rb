require_relative '../../../app/controllers/multiplayer_game'
require_relative '../../../app/multiplayer_game'
require_relative '../../../app/game/dictionary/test'

describe Controllers::MultiplayerGame do
  let(:message) { }
  let(:connection) { double(:connection, send: nil) }
  let(:publisher) { double(:publisher, subscribe: nil, publish: nil) }

  subject { described_class.new(connection, message) }

  before do
    $live_games = {}
    $publisher = publisher
  end

  describe '#join' do
    context 'when the game is not found' do
      let(:message) { { 'type' => 'join', 'game_id' => 'not_existed', 'channel' => 'test'} }

      it 'sends an error message' do
        subject.run

        expect(connection).to have_received(:send).with({
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
                                   started?: false, player_exists?: false, dictionary: double(name: 'en')) }
      let(:fake_player_id) { 'fake_uuid' }

      before do
        $live_games['game_id'] = game
      end

      before do
        allow(SecureRandom).to receive(:uuid).and_return(fake_player_id)
      end

      it 'sends a success message' do
        subject.run

        expect(connection).to have_received(:send) do |message|
          json_payload = JSON.parse(message, symbolize_names: true)
          expect(json_payload).to include({status: 'ok',
                                           type: 'join',
                                           data: {player_id: fake_player_id, players: [], dictionary_name: 'en', start_time: nil},
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

        it 'sends a success message' do
          subject.run

          expect(connection).to have_received(:send) do |message|
            json_payload = JSON.parse(message, symbolize_names: true)
            expect(json_payload).to include({status: 'ok',
                                             type: 'join',
                                             data: {player_id: existing_player_id, players: [], dictionary_name: 'en', start_time: nil},
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

      it 'sends players data and game start time in the response' do
        subject.run

        expect(connection).to have_received(:send) do |response|
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

        expect(connection).to have_received(:send) do |response|
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

        expect(connection).to have_received(:send) do |response|
          json_response = JSON.parse(response)
          expect(json_response['data']['player_name']).to eq(new_player_name)
        end
      end

      context 'with russian letters' do
        let(:new_player_name) { '??????' }

        it 'updates a player name' do
          subject.run

          expect(connection).to have_received(:send) do |response|
            json_response = JSON.parse(response)
            expect(json_response['data']['player_name']).to eq(new_player_name)
          end
        end
      end

      context 'with invalid name' do
        let(:new_player_name) { 'x' }

        it 'sends an error message' do
          subject.run

          expect(connection).to have_received(:send).with({
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

        it 'creates a new one and sends it id' do
          subject.run

          expect(connection).to have_received(:send) do |response|
            json_response = JSON.parse(response)
            expect(json_response['data']['game_id']).to match(/\A\w+\z/)
          end
        end
      end
    end
  end
end
