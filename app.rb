require_relative './app/game'

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

          if $games[game_id]
            {status: 'ok', message: {game: {status: $games[game_id].status, attempts: $games[game_id].attempts}}}
          else
            {status: 'error', message: 'Game not found'}
          end
        when "attempt"
          game_id = msg["game_id"]

          if game = $games[game_id]
            begin
              attempt_result = game.attempt(msg["word"])
              {status: 'ok', message: {game: {status: $games[game_id].status, attempts: $games[game_id].attempts}}}
            rescue ArgumentError => e
              {status: 'error', message: e.message}
            end
          else
            {status: 'error', message: 'Game not found'}
          end
        end

      conn.send(JSON.generate(response))
    end
  rescue => e
    puts e
  end

  GAME_HTML = IO.read(File.join(__dir__, 'public/game.html'))
  def call(env)
    req = Rack::Request.new(env)
    if req.path == '/new'
      game_id = SecureRandom.uuid
      $games[game_id] = Game.new('plain')
      [302, {'Location' => "/games/#{game_id}"}, []]
    elsif req.path.match?(/games\/(.*)/)
      [200, {'Location' => "/games/#{game_id}"}, [GAME_HTML]]
    else
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    end
  end
end
