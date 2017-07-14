module MiniMqtt
  class PubrecPacket < Packet
    include AckPacket
    register_packet_type 5
  end
end
