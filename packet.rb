require 'bin_helper'

class InvalidFlagsError < StandardError ; end

class Packet
  include BinHelper

  attr_accessor :length

  def decode stream, length
    @stream = stream
    @length = length
    read_variable_header
    read_payload
    self
  end

  def encode
    # Build variable header and payload, set length and return the encoded packet
    bytes = build_variable_header + build_payload
    self.length = bytes.length
    bytes
  end

  def flags
    0b0000
  end

  private

    def read_variable_header
    end

    def read_payload
    end

    def build_variable_header
      ""
    end

    def build_payload
      ""
    end
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

require 'connect_packet'
