require 'test_helper'

class TestPacketHandler < Minitest::Test
  def setup
    @socket = StringIO.new
    @handler = PacketHandler.new @socket
  end

  def test_get_packet
    @socket.write "\x10\x00"
    @socket.write "\xa2\x05topic"
    @socket.rewind
    packet = @handler.get_packet
    assert_equal ConnectPacket, packet.class

    packet = @handler.get_packet
    assert_equal UnsubscribePacket, packet.class
  end

  def test_write_packet
    packet = ConnectPacket.new client_id: 'abc'
    @handler.write_packet packet
    @socket.rewind
    assert_equal 0x10, @socket.readbyte # packet type and flags
    assert_equal 0x0F, @socket.readbyte # encoded length
    assert_equal @socket.read, packet.encode
  end

  def test_length_decoding
    assert_equal 321, @handler.send(:decode_length, "\xC1\x02".to_stream)
    assert_equal 16384, @handler.send(:decode_length, "\x80\x80\x01".to_stream)
    assert_equal 268_435_455, @handler.send(:decode_length, "\xFF\xFF\xFF\x7F".to_stream)
    assert_raises StandardError do
      @handler.send(:decode_length, "\xFF\xFF\xFF\xFF".to_stream)
    end
  end
end
