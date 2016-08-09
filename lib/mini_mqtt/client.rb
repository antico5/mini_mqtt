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
        Session.new @packet_handler
      else
        raise StandardError.new(connack.error)
      end
    end

      def generate_client_id
        "id_#{ rand(10000).to_s }"
      end
  end
end
