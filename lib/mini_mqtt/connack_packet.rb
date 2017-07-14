module MiniMqtt
  class ConnackPacket < Packet
    attr_reader :return_code
    register_packet_type 2

    ERRORS = { 1 => "unacceptable protocol version",
               2 => "identifier rejected",
               3 => "server unavailable",
               4 => "bad username or password",
               5 => "not authorized" }


    def read_variable_header
      @session_present = @stream.readbyte & 0x01
      @return_code = @stream.readbyte
    end

    def session_present?
      @session_present == 1
    end

    def accepted?
      @return_code == 0
    end

    def error_message
      ERRORS[@return_code]
    end
  end
end
