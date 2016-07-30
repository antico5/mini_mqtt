PACKET_CLASSES = { 1 => :connect,
                   2 => :connack,
                   3 => :publish,
                   4 => :puback,
                   5 => :pubrec,
                   6 => :pubrel,
                   7 => :pubcomp,
                   8 => :subscribe,
                   9 => :suback,
                   10 => :unsubscribe,
                   11 => :unsuback,
                   12 => :pingreq,
                   13 => :pingresp,
                   14 => :disconnect }

class Packet
  MAX_LENGTH_MULTIPLIER = 128 ** 3

  attr_reader :type, :flags, :length, :body

  def initialize stream
    first_byte = stream.readbyte
    @type = PACKET_CLASSES[ first_byte >> 4 ]
    @flags = first_byte & 0xf
    @length = decode_length stream
    @body = stream.read @length
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

stream = StringIO.new "\x13\x09holaperro"
p1 = Packet.new stream



