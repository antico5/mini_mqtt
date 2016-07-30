$:.unshift File.dirname __FILE__
require 'minitest/autorun'
require 'pry'
require 'packet_reader'
require 'packet'


class String
  def to_stream
    StringIO.new self
  end
end

class TestPacketReader < Minitest::Test
  def setup
    @socket = StringIO.new
    connect_packet_bytes = "\x10\x00"
    unsubscribe_packet_bytes = "\xa2\x05topic"
    @socket.write connect_packet_bytes
    @socket.write unsubscribe_packet_bytes
    @socket.rewind
    @reader = PacketReader.new @socket
  end

  def test_get_packet
    packet = @reader.get_packet
    assert_equal ConnectPacket, packet.class
    assert_equal 0, packet.length

    packet = @reader.get_packet
    assert_equal UnsubscribePacket, packet.class
    assert_equal 5, packet.length
  end

  def test_length_decoding
    assert_equal 321, @reader.send(:decode_length, "\xC1\x02".to_stream)
    assert_equal 16384, @reader.send(:decode_length, "\x80\x80\x01".to_stream)
    assert_equal 268_435_455, @reader.send(:decode_length, "\xFF\xFF\xFF\x7F".to_stream)
    assert_raises StandardError do
      @reader.send(:decode_length, "\xFF\xFF\xFF\xFF".to_stream)
    end
  end

end

