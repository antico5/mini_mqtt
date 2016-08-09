module MiniMqtt
  class Session
    def initialize packet_handler
      @handler = packet_handler

      # Initialize ping timers
      @last_ping_response = Time.now
      # Spawn threads to receive incoming packets and send ping requests
      # asynchronously
      spawn_read_thread!
      spawn_keepalive_thread!
    end

    def subscribe topic
      packet = SubscribePacket.new topics: {topic => 0}
      @handler.write_packet packet
    end

    def publish topic, message
      packet = PublishPacket.new topic: topic, message: message
      @handler.write_packet packet
    end

    def disconnect
      # Send DisconnectPacket and kill read thread.
      @handler.write_packet DisconnectPacket.new
      kill_threads!
    end

    private

      def spawn_read_thread!
        @read_thread = Thread.new do
          begin
            loop do
              @handler.get_packet
            end
          rescue Exception => e
            puts e.inspect
          end
        end
      end

      def spawn_keepalive_thread!
        @keepalive_thread = Thread.new do
          loop do
            sleep @keep_alive
            @handler.write_packet PingreqPacket.new
          end
        end
      end

      def kill_threads!
        @read_thread.kill
        @keepalive_thread.kill
      end
  end
end
