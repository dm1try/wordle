require_relative './base'
require_relative '../multiplayer_game'

module Controllers
  class MultiplayerGame < Base

    def join
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game

      player_id = message["player_id"]

      unless game.player_exists?(player_id)
        return error(:game_already_started) if game.started?

        player_id = SecureRandom.uuid
        player_name = message["player_name"] || "Wordler #{game.players.size + 1}"
        game.add_player(player_id, player_name)

        # Persist game state after adding player
        $game_repository.save(game_id, game)

        $publisher.publish(game_id, :player_joined, {player: {id: player_id, name: player_name}}, conn)
      end
      $publisher.subscribe(game_id, conn)

      players = game.players.map { |p| {id: p.id, name: p.name, attempts: p.attempts} }
      start_time = iso8601(game.start_time) if game.started?
      ok(player_id: player_id, players: players, dictionary_name: game.dictionary.name, start_time: start_time)
    end

    def start
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game
      return error(:game_already_started) if game.started?

      game.start

      # Persist game state after starting
      $game_repository.save(game_id, game)

      payload = {start_time: iso8601(game.start_time) }
      $publisher.publish(game_id, :game_started, payload)

      ok(payload)
    end

    def attempt
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game
      return error(:game_not_started) unless game.started?
      return error(:attempt_word_not_found) unless game.word_available?(message["word"])

      player_game = game.attempt(message["player_id"], message["word"])

      # Persist game state after attempt
      $game_repository.save(game_id, game)

      case player_game.status
      when :won, :lost
        ok(attempt_result: player_game.status, game: {status: player_game.status, attempts: player_game.attempts})
        $publisher.publish(game_id, :player_ended_game, {player_id: message["player_id"], match: player_game.last_match}, conn)
      else
        ok(attempt_result: :word_found, game: {status: player_game.status, attempts: player_game.attempts})
        $publisher.publish(game_id, :player_found_word,
                              {player_id: message["player_id"], match: player_game.last_match}, conn)
      end

      if game.ended?
        $publisher.publish(game_id, :game_ended, winner_id: game.winner.id, end_time: iso8601(game.end_time))
      end
    end

    def update_name
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game

      player_id = message["player_id"]
      player_name = message["player_name"]

      return error(:invalid_name) if !player_name || !player_name.match(/^[a-zA-Zа-яА-Я0-9_]{3,20}$/)

      game.update_player_name(player_id, player_name)
      
      # Persist game state after name update
      $game_repository.save(game_id, game)
      
      $publisher.publish(game_id, :player_name_updated, {player_id: player_id, player_name: player_name}, conn)

      ok(player_id: player_id, player_name: player_name)
    end

    def repeat
      game_id = message["game_id"]
      game = $live_games[game_id]

      return error(:game_not_found) unless game

      new_game_id = SecureRandom.hex(3)
      new_game = ::MultiplayerGame.new(game.dictionary)
      $live_games[new_game_id] = new_game
      
      # Persist new game
      $game_repository.save(new_game_id, new_game)

      $publisher.publish(game_id, :repeat_game_created, {game_id: new_game_id}, conn)
      ok(game_id: new_game_id)
    end

    private

    def iso8601(date)
      date.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
    end

  end
end
