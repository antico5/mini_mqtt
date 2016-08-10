require 'socket'

module MiniMqtt
  class Client
    attr_accessor :host, :port, :user, :password, :clean_session

    def initialize params = {}
      @host = params[:host]
      @port = params[:port]
      @user = params[:user]
      @password = params[:password]
      @keep_alive = params[:keep_alive] || 15
      @client_id = params[:client_id] || generate_client_id
      @clean_session = params.fetch :clean_session, true
    end

    def connect
      # Create socket and packet handler
      @socket = TCPSocket.new @host, @port
      @packet_handler = PacketHandler.new @socket
      @packet_handler.debug = true

      # Send ConnectPacket
      @packet_handler.write_packet ConnectPacket.new user: @user,
        password: @password, keep_alive: @keep_alive, client_id: @client_id,
        clean_session: @clean_session

      # Receive connack packet
      connack = @packet_handler.get_packet

      if connack.accepted?
        @received_messages = []
        @last_ping_response = Time.now
        spawn_read_thread!
        spawn_keepalive_thread!
      else
        raise StandardError.new(connack.error)
      end
    end

    def subscribe topic
      packet = SubscribePacket.new topics: {topic => 0}
      @packet_handler.write_packet packet
    end

    def publish topic, message
      packet = PublishPacket.new topic: topic, message: message
      @packet_handler.write_packet packet
    end

    def disconnect
      # Send DisconnectPacket, close socket and kill threads
      @packet_handler.write_packet DisconnectPacket.new
      kill_threads!
      @socket.close
    end

    private

      def handle_received_packet packet
        case packet
        when PingrespPacket
          @last_ping_response = Time.now
        end
      end

      def generate_client_id
        "id_#{ rand(10000).to_s }"
      end

      def spawn_read_thread!
        @read_thread = Thread.new do
          begin
            loop do
              # read packet from socket and handle it
              handle_received_packet @packet_handler.get_packet
            end
          rescue Exception => e
            puts e.inspect
          end
        end
      end

      def spawn_keepalive_thread!
        @keepalive_thread = Thread.new do
          loop do
            @handler.write_packet PingreqPacket.new
            sleep @keep_alive
            if Time.now - @last_ping_response > @keep_alive
              puts "SERVER NOT RESPONDING TO PING."
            end
          end
        end
      end

      def kill_threads!
        @read_thread.kill
        @keepalive_thread.kill
      end
  end
end
