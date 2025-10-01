require_relative '../../../app/controllers/simple_game'
require_relative '../../../app/game'

describe Controllers::SimpleGame do
  let(:message) { }
  let(:connection) { double(:connection, write: nil) }
  let(:publisher) { double(:publisher, subscribe: nil, publish: nil) }

  subject { Controllers::SimpleGame.new(connection, message) }

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
      let(:game) { instance_double(Game, status: :in_progress, attempts: []) }

      before do
        $live_games['game_id'] = game
      end

      it 'writes a success message' do
        subject.run

        expect(connection).to have_received(:write).with({
          status: 'ok',
          type: :join,
          data: {game: {status: game.status, attempts: game.attempts}},
          channel: 'test'
        }.to_json)
      end
    end
  end

  describe '#attempt' do
    context 'when the game is not found' do
      let(:message) { { 'type' => 'attempt', 'game_id' => 'not_existed', 'channel' => 'test'} }

      it 'should return an error message' do
        subject.run

        expect(connection).to have_received(:write).with({
          status: 'error',
          type: :attempt,
          data: {error: :game_not_found, message: 'Game not found'},
          channel: 'test'
        }.to_json)
      end
    end

    context 'when the game is found' do
      let(:message) { { 'type' => 'attempt', 'game_id' => 'game_id', 'channel' => 'test', 'attempt' => 'test'} }
      let(:game) { instance_double(Game, status: :in_progress, attempts: []) }

      before do
        $live_games['game_id'] = game
      end

      context 'when word is not available in game dictionary' do
        let(:game) { instance_double(Game, status: :in_progress, attempts: [], word_available?: false) }
          it 'should return a success message' do
            subject.run

            expect(connection).to have_received(:write).with({
              status: 'ok',
              type: :attempt,
              data: {attempt_result: :word_not_available},
              channel: 'test'
            }.to_json)
        end
      end

      context 'when game had been won' do
        let(:game) { instance_double(Game, status: :won, attempts: [2,2,2,2,2], word_available?: true, attempt: nil) }

        it 'should return a success message' do
          subject.run

          expect(connection).to have_received(:write).with({
            status: 'ok',
            type: :attempt,
            data: {attempt_result: :won, game: {status: game.status, attempts: game.attempts}},
            channel: 'test'
          }.to_json)
        end
      end

      context 'when game had been lost' do
        let(:game) { instance_double(Game, status: :lost, attempts: [2,2,2,2,0], word_available?: true, attempt: nil) }

        it 'should return a success message' do
          subject.run

          expect(connection).to have_received(:write).with({
            status: 'ok',
            type: :attempt,
            data: {attempt_result: :lost, game: {status: game.status, attempts: game.attempts}},
            channel: 'test'
          }.to_json)
        end
      end

      context 'when game had been lost' do
        let(:game) { instance_double(Game, status: :in_progress, attempts: [2,0,2,2,2], word_available?: true, attempt: nil) }

        it 'should return a success message' do
          subject.run

          expect(connection).to have_received(:write).with({
            status: 'ok',
            type: :attempt,
            data: {attempt_result: :word_found, game: {status: game.status, attempts: game.attempts}},
            channel: 'test'
          }.to_json)
        end
      end
    end
  end
end
