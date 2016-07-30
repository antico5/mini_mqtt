require 'bin_helper'

class InvalidFlagsError < StandardError ; end

class Packet
  include BinHelper

  def decode stream
    @stream = stream
    read_variable_header
    read_payload
    self
  end

  def encode
    build_variable_header + build_payload
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
  attr_reader :return_code

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
