class App
  def self.build
    Rack::Builder.new do
      use Rack::Static, :urls => {"/" => "new.html"}, :root => "public"
      run App.new
    end
  end

  def call(env)
    [200, {'Content-Type' => 'text/html'}, ['Game']]
  end
end
