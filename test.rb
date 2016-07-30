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
