module MiniMqtt
  class UnsubackPacket < Packet
    include AckPacket
    register_packet_type 11
  end
end
