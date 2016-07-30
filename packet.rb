class Packet
  attr_reader :body, :flags
  def initialize body, flags = 0
    @body = body
    @flags = flags
  end
end

class ConnectPacket < Packet
end

class ConnackPacket < Packet
end

class PublishPacket < Packet
end

class PubackPacket < Packet
end

class PubrecPacket < Packet
end

class PubrelPacket < Packet
end

class PubcompPacket < Packet
end

class SubscribePacket < Packet
end

class SubackPacket < Packet
end

class UnsubscribePacket < Packet
end

class UnsubackPacket < Packet
end

class PingreqPacket < Packet
end

class PingrespPacket < Packet
end

class DisconnectPacket < Packet
end
