require 'packet'

PACKET_CLASSES = { 1 => ConnectPacket,
                   2 => ConnackPacket,
                   3 => PublishPacket,
                   4 => PubackPacket,
                   5 => PubrecPacket,
                   6 => PubrelPacket,
                   7 => PubcompPacket,
                   8 => SubscribePacket,
                   9 => SubackPacket,
                   10 => UnsubscribePacket,
                   11 => UnsubackPacket,
                   12 => PingreqPacket,
                   13 => PingrespPacket,
                   14 => DisconnectPacket }
PACKET_CODES = PACKET_CLASSES.invert

class PacketHandler
  include BinHelper

  MAX_LENGTH_MULTIPLIER = 128 ** 3

  def initialize stream
    @stream = stream
  end

  def get_packet
    first_byte = @stream.readbyte
    packet_class = PACKET_CLASSES[ first_byte >> 4 ]
    flags = first_byte & 0xf
    length = decode_length @stream
    encoded_packet = @stream.read length
    packet_class.new.decode StringIO.new(encoded_packet)
  end

  def write_packet packet
    type_and_flags = PACKET_CODES[packet.class] << 4
    type_and_flags += packet.flags
    @stream.write uchar(type_and_flags)
    encoded_packet = packet.encode
    @stream.write encode_length(encoded_packet.length)
    @stream.write encoded_packet
  end

  private

  def encode_length length
    encoded = ""
    while length > 0
      encoded_byte = length % 128
      length = length / 128
      encoded_byte |= 128 if length > 0
      encoded << encoded_byte.chr
    end
    encoded
  end

  def decode_length stream
    length = 0
    multiplier = 1
    while encoded_byte = stream.readbyte
      length += (encoded_byte & 0x7f) * multiplier
      break if encoded_byte & 0x80 == 0
      multiplier *= 128
      raise "Malformed remaining length" if multiplier > MAX_LENGTH_MULTIPLIER
    end
    length
  end
end

