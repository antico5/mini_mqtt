module MiniMqtt
  class PubcompPacket < Packet
    include AckPacket
    register_packet_type 7
  end
end
