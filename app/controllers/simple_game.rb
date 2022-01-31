require_relative './base'

module Controllers
  class SimpleGame < Base

    def join
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game

      $publisher.subscribe(game_id, conn)
      ok(game: {status: game.status, attempts: game.attempts})
    end

    def attempt
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game

      word = message["word"]
      return ok(attempt_result: :word_not_available) unless game.word_available?(word)

      begin
        game.attempt(word)

        case game.status
        when :won
          ok(attempt_result: :won, game: {status: game.status, attempts: game.attempts})
        when :lost
          ok(attempt_result: :lost, game: {status: game.status, attempts: game.attempts})
        else
          ok(attempt_result: :word_found, game: {status: game.status, attempts: game.attempts})
        end

        $publisher.publish(game_id, :game_updated, {game: {status: game.status, attempts: game.attempts}}, conn)
      rescue ArgumentError => e
        error(:argument_error, message: e.message)
      end
    end
  end
end
