app_path = File.expand_path('./config.ru', __dir__)
app = Tipi::RackAdapter.load(app_path)

opts = {
  reuse_addr:  true,
  dont_linger: true,
  upgrade:     {
    websocket: Tipi::Websocket.handler(&App.method(:ws_handler))
  }
}

port = ENV['PORT'] || 1234

server = spin do
  Tipi.serve('0.0.0.0', port, opts, &app)
end

supervise(server, restart: :on_error) do |server, exception|
  puts 'Server is down, restarting...'
  puts "Error message: #{exception.message}"
  server.restart
end
