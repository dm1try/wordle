require 'bundler/setup'
require 'iodine'
require 'rack'
require 'json'
require 'securerandom'

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

# WebSocket handler module for Iodine
module WebSocketHandler
  def on_open(client)
    puts "WebSocket connection opened"
  end

  def on_message(client, data)
    begin
      msg = JSON.parse(data)

      if msg["channel"] == "multiplayer"
        ::Controllers::MultiplayerGame.new(client, msg).run
      else
        ::Controllers::SimpleGame.new(client, msg).run
      end
    rescue => e
      puts "Error in on_message: #{e}"
      puts e.backtrace
    end
  end

  def on_close(client)
    puts "WebSocket connection closed"
    # Note: We could track connections here and unsubscribe, but we'll handle that in the publisher
  end
  
  extend self
end

# Rack application
class App
  GAME_HTML_PATH = File.join(__dir__, 'public', 'game.html')
  MULTIPLAYER_GAME_HTML_PATH = File.join(__dir__, 'public', 'multiplayer_game.html')

  def self.call(env)
    # Handle WebSocket upgrade
    if env['rack.upgrade?'.freeze] == :websocket
      env['rack.upgrade'.freeze] = WebSocketHandler
      return [0, {}, []]
    end

    request = Rack::Request.new(env)
    path = request.path_info

    # Handle root path
    if path == '/'
      return serve_file(File.join(__dir__, 'public', 'new.html'))
    end

    # Handle static files
    if path.start_with?('/js/')
      return serve_file(File.join(__dir__, 'public', path))
    end

    if path.start_with?('/css/')
      return serve_file(File.join(__dir__, 'public', path))
    end

    # Handle /new endpoint
    if path == '/new'
      game_id = SecureRandom.hex(3)

      guesses_set_name = 'words'
      available_words_set_name = 'available_words'
      dictionary_name = 'ru'

      if request.params['dictionary'] == 'en'
        guesses_set_name = 'words_en'
        available_words_set_name = 'available_words_en'
        dictionary_name = 'en'
      end

      game_dictionary = Game::Dictionary::Redis.new($redis, guesses_set_name,
                                                    available_words_set_name, dictionary_name)

      $live_games[game_id] =
        if request.params['mode'] == 'time_competition'
          MultiplayerGame.new(game_dictionary)
        else
          Game.new(game_dictionary)
        end

      return [302, {'Location' => "/games/#{game_id}"}, []]
    end

    # Handle /games/:id endpoint
    if path.start_with?('/games/')
      game_id = path.split('/').last

      case $live_games[game_id]
      when Game
        return serve_file(GAME_HTML_PATH)
      when MultiplayerGame
        return serve_file(MULTIPLAYER_GAME_HTML_PATH)
      else
        return [302, {'Location' => '/'}, []]
      end
    end

    # 404 Not Found
    [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
  end

  def self.serve_file(path)
    if File.exist?(path)
      content = File.read(path)
      content_type = case File.extname(path)
                     when '.html' then 'text/html'
                     when '.js' then 'application/javascript'
                     when '.css' then 'text/css'
                     else 'application/octet-stream'
                     end
      [200, {'Content-Type' => content_type}, [content]]
    else
      [404, {'Content-Type' => 'text/plain'}, ['File not found']]
    end
  end
end

port = ENV['PORT'] || 1234
Iodine.listen(service: :http, handler: App, port: port, address: '0.0.0.0')
Iodine.threads = -1
Iodine.workers = 1
puts "Starting Iodine server on port #{port}..."
Iodine.start
