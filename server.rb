app_path = File.expand_path('./config.ru', __dir__)
app = Tipi::RackAdapter.load(app_path)

def ws_handler(conn)
  while msg = conn.recv
    puts "Received: #{msg}"
    conn.send msg
  end
end

opts = {
  reuse_addr:  true,
  dont_linger: true,
  upgrade:     {
    websocket: Tipi::Websocket.handler(&method(:ws_handler))
  }
}

Tipi.serve('0.0.0.0', 1234, opts, &app)
