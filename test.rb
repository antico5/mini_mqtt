$:.unshift File.dirname __FILE__
require 'minitest/autorun'
require 'pry'
require 'packet_handler'
require 'packet'


class String
  def to_stream
    StringIO.new self
  end
end

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

class ConnectPacketTest < MiniTest::Test
  def test_encode_with_all_params
    packet = ConnectPacket.new user: 'arman',
                               password: 'secret',
                               client_id: 'abc',
                               will_message: 'I am dead',
                               will_topic: 'last_will',
                               will_retain: false,
                               will_qos: 0,
                               clean_session: true,
                               keep_alive: 20
    encoded = packet.encode
    assert_equal "\x00\x04MQTT", encoded[0..5]
    assert_equal "\x04", encoded[6]
    assert_equal [0xc6], encoded[7].bytes
    assert_equal "\x00\x14", encoded[8..9]
    assert_equal "\x00\x03abc", encoded[10..14]
    assert_equal "\x00\x09last_will", encoded[15..25]
    assert_equal "\x00\x09I am dead", encoded[26..36]
    assert_equal "\x00\x05arman", encoded[37..43]
    assert_equal "\x00\x06secret", encoded[44..-1]
  end

  def test_encode_without_params
    packet = ConnectPacket.new client_id: 'abc'
    encoded = packet.encode
    assert_equal "\x00\x04MQTT", encoded[0..5]
    assert_equal "\x04", encoded[6]
    assert_equal [0x02], encoded[7].bytes
    assert_equal "\x00\x0F", encoded[8..9]
    assert_equal "\x00\x03abc", encoded[10..-1]
  end
end

class ConnackPacketTest < MiniTest::Test
  def test_decode_accepted_connection
    packet = ConnackPacket.new
    packet.decode "\x01\x00".to_stream
    assert true, packet.session_present?
    assert true, packet.accepted?
  end
end
