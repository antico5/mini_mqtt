module MiniMqtt
  class PubackPacket < Packet
    include AckPacket
    register_packet_type 4
  end
end
