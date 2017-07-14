module MiniMqtt
  class SubackPacket < Packet
    attr_accessor :packet_id, :max_qos_accepted
    register_packet_type 9

    def read_variable_header
      @packet_id = read_ushort @stream
    end

    def read_payload
      @max_qos_accepted = @stream.read.unpack 'C*'
    end
  end
end
