require 'socket'

module MiniMqtt
  class Client
    attr_accessor :host, :port, :user, :password

    def initialize params = {}
      @host = params[:host]
      @port = params[:port]
      @user = params[:user]
      @password = params[:password]
    end

    def connect
      # Create socket and packet handler
      @socket = TCPSocket.new @host, @port
      @packet_handler = PacketHandler.new @socket
      @packet_handler.debug = true

      #Spawn read thread to receive incoming packets
      spawn_read_thread!

      # Send ConnectPacket
      @packet_handler.write_packet ConnectPacket.new user: @user,
        password: @password

      # Create new session and yield to caller
      session = Session.new @packet_handler
      yield session

      # Send DisconnectPacket and kill read thread.
      @packet_handler.write_packet DisconnectPacket.new
      kill_read_thread!
    end

    private

      def spawn_read_thread!
        @read_thread = Thread.new do
          begin
            loop do
              @packet_handler.get_packet
            end
          rescue Exception => e
            puts e.inspect
          end
        end
      end

      def kill_read_thread!
        @read_thread.kill
      end
  end
end
