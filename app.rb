require_relative './app/game'
require_relative './app/game/dictionary/redis'
$games = {}

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
      response =
        case msg["type"]
        when "join"
          game_id = msg["game_id"]

          $publisher.subscribe(game_id, conn)

          if $games[game_id]
            {status: 'ok', message: {game: {status: $games[game_id].status, attempts: $games[game_id].attempts}}}
          else
            {status: 'error', message: 'Game not found'}
          end
        when "attempt"
          game_id = msg["game_id"]

          if game = $games[game_id]
            begin
              if game.word_available?(msg["word"])
                game.attempt(msg["word"])
                {status: 'ok', message: {game: {status: game.status, attempts: game.attempts}}}
              else
                {status: 'error', message: 'Word not found'}
              end
            rescue ArgumentError => e
              {status: 'error', message: e.message}
            end
          else
            {status: 'error', message: 'Game not found'}
          end
        end

      conn.send(JSON.generate(response))
      $publisher.publish(game_id, JSON.generate(response), conn)
    end
  rescue => e
   $publisher.unsubscribe(game_id, conn)
    puts e
  end

  GAME_HTML = IO.read(File.join(__dir__, 'public/game.html'))
  def call(env)
    req = Rack::Request.new(env)
    if req.path == '/new'
      game_id = SecureRandom.uuid
      game_dictionary = Game::Dictionary::Redis.new($redis, 'words', 'available_words')
      $games[game_id] = Game.new(game_dictionary)
      [200, {'Content-Type' => 'text/html'}, [GAME_HTML.gsub('{{game_id}}', game_id)]]
      [302, {'Location' => "/games/#{game_id}"}, []]
    elsif req.path.match?(/games\/(.*)/)
      [200, {'Location' => "/games/#{game_id}"}, [GAME_HTML]]
    else
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    end
  end
end
