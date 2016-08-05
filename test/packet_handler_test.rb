require 'test_helper'

class TestPacketHandler < Minitest::Test
  def setup
    @socket = StringIO.new
    @handler = PacketHandler.new @socket
  end

  def test_get_packet
    @socket.write "\xd0\x00"
    @socket.write "\xa2\x05topic"
    @socket.rewind
    packet = @handler.get_packet
    assert_equal PingrespPacket, packet.class

    packet = @handler.get_packet
    assert_equal UnsubscribePacket, packet.class
  end

  def test_write_pingreq_packet
    packet = PingreqPacket.new
    @handler.write_packet packet
    @socket.rewind
    assert_equal 0xc0, @socket.readbyte # packet type and flags
    assert_equal 0x00, @socket.readbyte # encoded length
  end

  def test_write_connect_packet
    packet = ConnectPacket.new client_id: 'abc', keep_alive: 15
    @handler.write_packet packet
    @socket.rewind
    assert_equal 0x10, @socket.readbyte # packet type and flags
    assert_equal 0x0F, @socket.readbyte # encoded length
    assert_equal @socket.read, packet.encode
  end

  def test_length_encoding
    assert_equal [0x00], @handler.send(:encode_length, 0).bytes
    assert_equal [0xc1,0x02], @handler.send(:encode_length, 321).bytes
    assert_equal [0x80,0x80,0x01], @handler.send(:encode_length, 16384).bytes
    assert_equal [0xff,0xff,0xff,0x7f], @handler.send(:encode_length, 268_435_455).bytes
  end

  def test_length_decoding
    assert_equal 0, @handler.send(:decode_length, "\x00".to_stream)
    assert_equal 321, @handler.send(:decode_length, "\xC1\x02".to_stream)
    assert_equal 16384, @handler.send(:decode_length, "\x80\x80\x01".to_stream)
    assert_equal 268_435_455, @handler.send(:decode_length, "\xFF\xFF\xFF\x7F".to_stream)
    assert_raises StandardError do
      @handler.send(:decode_length, "\xFF\xFF\xFF\xFF".to_stream)
    end
  end
end
