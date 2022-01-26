class App
  def self.build
    Rack::Builder.new do
      use Rack::Static, :urls => {"/" => "new.html"}, :root => "public"
      run App.new
    end
  end

  def self.ws_handler(conn)
    while msg = JSON.parse(conn.recv)
      puts "Received: #{msg}"
      conn.send msg
    end
  end

  GAME_HTML = IO.read(File.join(__dir__, 'public/game.html'))
  def call(env)
    [200, {'Content-Type' => 'text/html'}, [GAME_HTML]]
  end
end
