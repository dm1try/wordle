require 'json'

module Controllers
  class Base
    attr_reader :conn, :message, :channel

    def initialize(conn, message)
      @conn = conn
      @message = message
      @channel = message["channel"]
    end

    def run
      send(@message["type"])
    end

    def ok(data = nil)
      type = message["type"]
      send_data({status: 'ok', type: type, data: data})
    end

    def error(key, description = nil)
      type = message["type"]
      description ||= key.to_s.capitalize.gsub('_', ' ')
      data = {error: key, message: description}
      send_data({status: 'error', type: type, data: data})
    end

    def send_data(data)
      data["channel"] = @channel
      json_data = JSON.generate(data)
      @conn.send(json_data)
    end
  end
end
