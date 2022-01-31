require_relative './app/game'
require_relative './app/multiplayer_game'
require_relative './app/game/dictionary/redis'
require_relative './app/controllers/simple_game'
require_relative './app/controllers/multiplayer_game'

$live_games = {}

class App
  def self.build
    Rack::Builder.new do
      use Rack::Static, :urls => ["/js", "/css"], :root => "public"
      use Rack::Static, :urls => {"/" => "new.html"}, :root => "public"
      run App.new
    end
  end

  def self.ws_handler(conn)
    while msg = JSON.parse(conn.recv)
      if msg["channel"] == "multiplayer"
        ::Controllers::MultiplayerGame.new(conn, msg).run
      else
        ::Controllers::SimpleGame.new(conn, msg).run
      end
    end
  rescue => e
#   $publisher.unsubscribe(game_id, conn)
    puts e
  end

  GAME_HTML = IO.read(File.join(__dir__, 'public/game.html'))
  MULTIPLAYER_GAME_HTML = IO.read(File.join(__dir__, 'public/multiplayer_game.html'))

  def call(env)
    # BUG: tipi does not forward query params
    req = Rack::Request.new(env)

    if req.path == '/new'
      game_id = SecureRandom.uuid
      game_dictionary = Game::Dictionary::Redis.new($redis, 'words', 'available_words')
      $live_games[game_id] = Game.new(game_dictionary)

      [302, {'Location' => "/games/#{game_id}"}, []]
    elsif req.path == '/new_multiplayer'
      game_id = SecureRandom.uuid

      game_dictionary = Game::Dictionary::Redis.new($redis, 'words', 'available_words')
      $live_games[game_id] = MultiplayerGame.new(game_dictionary)

      [302, {'Location' => "/games/#{game_id}"}, []]
    elsif req.path.match(/games\/(.*)/)
      game_id = $1

      case $live_games[game_id]
      when Game
        [200, {'Content-Type' => 'text/html'}, [GAME_HTML]]
      when MultiplayerGame
        [200, {'Content-Type' => 'text/html'}, [MULTIPLAYER_GAME_HTML]]
      else
        [200, {'Content-Type' => 'text/html'}, [GAME_HTML]]
      end
    else
      [404, {'Content-Type' => 'text/html'}, []]
    end
  end
end
