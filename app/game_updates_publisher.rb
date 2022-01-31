require 'polyphony'

class GameUpdatesPublisher
  def initialize
    @updates = Queue.new
    @connections = {}
  end

  def run
    spin do
      loop do
        game_id, type, payload, initiator = @updates.pop

        message = message(type, payload)

        puts "PUBLISHING: #{game_id} #{message}\n"

        if @connections[game_id].nil?
          puts "No connections for game #{game_id}"
          next
        end

        @connections[game_id].each do |connection|
          next if connection == initiator
          begin
            connection.send(message)
          rescue => e
            puts e.message
            @connections[game_id].delete(connection)
          end
        end
      end
    end
  end

  def subscribe(game_id, connection)
    @connections[game_id] ||= []
    @connections[game_id] << connection
  end

  def unsubscribe(game_id, connection)
    @connections[game_id] ||= []
    @connections[game_id].delete(connection)
  end

  def publish(game_id, type, payload, initiator = nil)
    @updates.push([game_id, type, payload, initiator])
  end

  def message(type, payload)
    data = {notify_type: type, data: payload}
    JSON.generate(data)
  end
end
