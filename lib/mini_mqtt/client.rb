require 'socket'

module MiniMqtt
  class Client
    attr_accessor :host, :port, :user, :password, :clean_session

    def initialize params = {}
      @host = params[:host] || localhost
      @port = params[:port] || 1883
      @user = params[:user]
      @password = params[:password]
      @keep_alive = params[:keep_alive] || 10
      @client_id = params[:client_id] || generate_client_id
      @clean_session = params.fetch :clean_session, true
    end

    def connect
      # Create socket and packet handler
      @socket = TCPSocket.new @host, @port
      @packet_handler = PacketHandler.new @socket

      # Send ConnectPacket
      send_packet ConnectPacket.new user: @user,
        password: @password, keep_alive: @keep_alive, client_id: @client_id,
        clean_session: @clean_session

      # Receive connack packet
      connack = receive_packet

      if connack.accepted?
        @received_messages = Queue.new
        @last_ping_response = Time.now
        spawn_read_thread!
        spawn_keepalive_thread!
      else
        raise StandardError.new(connack.error)
      end
    end

    def subscribe *params
      # Each param can be a topic or a topic with its max qos.
      # Example: subscribe 'topic1', 'topic2' => 1
      topics = params.map do |arg|
        arg.is_a?(Hash) ? arg : { arg => 0 }
      end
      topics = topics.inject &:merge
      packet = SubscribePacket.new topics: topics
      send_packet packet
    end

    def publish topic, message, options = {}
      packet = PublishPacket.new topic: topic, message: message.to_s,
        retain: options[:retain]
      send_packet packet
    end

    def disconnect
      # Send DisconnectPacket, then kill threads and close socket
      send_packet DisconnectPacket.new
      close_connection
    end

    def get_message
      message = @received_messages.pop
      yield message.message, message.topic
    end

    def connected?
      @socket && !@socket.closed?
    end

    private

      def send_packet packet
        begin
          @packet_handler.write_packet packet
        rescue StandardError => e
          puts "Exception while sending packet: #{ e.inspect }"
          close_connection
        end
      end

      def receive_packet
        begin
          @packet_handler.get_packet
        rescue StandardError => e
          puts "Exception while receiving: #{ e.inspect }"
          close_connection
        end
      end

      def handle_received_packet packet
        case packet
        when PingrespPacket
          @last_ping_response = Time.now
        when PublishPacket
          @received_messages << packet
        end
      end

      def generate_client_id
        "client_#{ rand(10000).to_s }"
      end

      def spawn_read_thread!
        @read_thread = Thread.new do
          loop do
            # read packet from socket and handle it
            handle_received_packet receive_packet
          end
        end
      end

      def spawn_keepalive_thread!
        @keepalive_thread = Thread.new do
          loop do
            send_packet PingreqPacket.new
            sleep @keep_alive
            if Time.now - @last_ping_response > @keep_alive
              puts "Error: Server not responding to ping. Disconnecting."
              close_connection
            end
          end
        end
      end

      def close_connection
        @read_thread.kill
        @keepalive_thread.kill
        @socket.close
      end
  end
end
