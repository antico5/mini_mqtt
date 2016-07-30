class Packet
  MAX_LENGTH_MULTIPLIER = 128 ** 3

  attr_reader :type, :flags
  def initialize bytes
    @bytes = bytes
    @type = bytes[0] >> 4
    @flags = bytes & 0xf
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

class p1 = Packet.new ""
