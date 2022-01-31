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
Tipi.serve('0.0.0.0', port, opts, &app)
