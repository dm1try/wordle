require 'bundler/setup'
require 'tipi'
require 'tipi/websocket'

require_relative './app/game'
require_relative './app/multiplayer_game'
require_relative './app/game/dictionary/redis'
require_relative './app/controllers/simple_game'
require_relative './app/controllers/multiplayer_game'


require_relative './db'
require_relative './app/game_updates_publisher'

$live_games = {}
$publisher = GameUpdatesPublisher.new
$publisher.run

class App
  def self.ws_handler(conn)
    while data = conn.recv
      break if data.nil? || data.empty?
      msg = JSON.parse(data)

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

  GAME_HTML_PATH = File.join(__dir__, 'public', 'game.html')
  MULTIPLAYER_GAME_HTML_PATH = File.join(__dir__, 'public', 'multiplayer_game.html')

  def self.tipi_app
    Tipi.route do |r|

      r.on_root do
        r.serve_file File.join(__dir__, 'public', 'new.html')
      end

      r.on 'js' do
        r.serve_file File.join(__dir__, 'public', r.path)
      end

      r.on 'css' do
        r.serve_file File.join(__dir__, 'public', r.path)
      end

      r.on 'new' do
        game_id = SecureRandom.hex(3)

        guesses_set_name = 'words'
        available_words_set_name = 'available_words'
        dictionary_name = 'ru'

        if r.query[:dictionary] == 'en'
          guesses_set_name = 'words_en'
          available_words_set_name = 'available_words_en'
          dictionary_name = 'en'
        end

        game_dictionary = Game::Dictionary::Redis.new($redis, guesses_set_name,
                                                      available_words_set_name, dictionary_name)

        $live_games[game_id] =
          if r.query[:mode] == 'time_competition'
            MultiplayerGame.new(game_dictionary)
          else
            Game.new(game_dictionary)
          end

        r.redirect "/games/#{game_id}"
      end

      r.on 'games' do
        game_id = r.path.split('/').last

        case $live_games[game_id]
        when Game
          r.serve_file GAME_HTML_PATH
        when MultiplayerGame
          r.serve_file MULTIPLAYER_GAME_HTML_PATH
        else
          r.redirect '/'
        end
      end

      r.respond("Not Found", {'Content-Type' => 'text/plain', ':status' => 404})
    end
  end
end

opts = {
  reuse_addr:  true,
  dont_linger: true,
  upgrade:     {
    websocket: Tipi::Websocket.handler(&App.method(:ws_handler))
  }
}

port = ENV['PORT'] || 1234
Tipi.serve('0.0.0.0', port, opts, &App.tipi_app)
