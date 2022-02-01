require_relative '../../../app/controllers/multiplayer_game'
require_relative '../../../app/multiplayer_game'

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

        expect(connection).to have_received(:send).with({
          status: 'ok',
          type: :join,
          data: {player_id: fake_player_id, players: [], dictionary_name: 'en'},
          channel: 'test'
        }.to_json)
      end

      context 'when player is already in the game' do
        let(:existing_player_id) { 'existing_player_id' }
        let(:message) { { 'type' => 'join', 'game_id' => 'game_id', 'channel' => 'test', 'player_id' => existing_player_id} }

        before do
          allow(game).to receive(:player_exists?).with(existing_player_id).and_return(true)
        end

        it 'sends a success message' do
          subject.run

          expect(connection).to have_received(:send).with({
            status: 'ok',
            type: :join,
            data: {player_id: existing_player_id, players: [], dictionary_name: 'en'},
            channel: 'test'
          }.to_json)
        end
      end
    end
  end
end
