module MiniMqtt
  class PubrelPacket < Packet
    include AckPacket
    register_packet_type 6

    def flags
      0b0010
    end
  end
end
