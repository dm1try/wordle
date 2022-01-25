class App
  def self.build
    Rack::Builder.new do
      use Rack::Static, :urls => {"/" => "new.html", "/game" => "game.html"}, :root => "public"
      run App.new
    end
  end

  def call(env)
    [200, {'Content-Type' => 'text/html'}, ['Hello World']]
  end
end
