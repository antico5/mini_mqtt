require 'bin_helper'

class InvalidFlagsError < StandardError ; end

class Packet
  include BinHelper

  attr_reader :flags

  def decode stream, flags = 0
    @stream = stream
    handle_flags flags
    read_variable_header
    read_payload
    self
  end

  def encode
    build_variable_header + build_payload
  end

  def flags
    0b000
  end

  private

    def read_variable_header
    end

    def read_payload
    end

    def handle_flags flags
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

class PublishPacket < Packet
  attr_accessor :dup, :qos, :retain
  def handle_flags flags
    @dup = flags & 0b1000 != 0
    @qos = (flags & 0b0110) >> 1
    @retain = flags & 0b0001 != 0
  end
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
