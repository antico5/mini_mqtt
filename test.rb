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
    assert packet.session_present?
    assert packet.accepted?
  end

  def test_decode_refused_connection
    packet = ConnackPacket.new
    packet.decode "\x00\x04".to_stream
    assert_equal false, packet.session_present?
    assert_equal false, packet.accepted?
    assert_match /bad username or password/, packet.error_message
  end
end

class PublishPacketTest < MiniTest::Test
  def setup
    @inbound_publish_1 = PublishPacket.new.decode "\x00\x03a/b\x00\x0aMessageHere".to_stream, 0b1011
    @inbound_publish_2 = PublishPacket.new.decode "\x00\x03a/bMessageHere".to_stream, 0b0000
    @outbound_publish_1 = PublishPacket.new topic: 'help', message: 'SOS'
    @outbound_publish_2 = PublishPacket.new topic: 'help', message: 'SOS',
      qos: 1, dup: true, retain: true, packet_id: 5
  end

  def test_read_flags
    assert @inbound_publish_1.dup
    assert @inbound_publish_1.retain
    assert_equal 1, @inbound_publish_1.qos

    refute @inbound_publish_2.dup
    refute @inbound_publish_2.retain
    assert_equal 0, @inbound_publish_2.qos
  end

  def test_decode_topic_and_packet_id
    assert_equal 'a/b', @inbound_publish_1.topic
    assert_equal 10, @inbound_publish_1.packet_id

    assert_equal 'a/b', @inbound_publish_2.topic
    assert_equal nil, @inbound_publish_2.packet_id
  end

  def test_decode_message
    assert_equal 'MessageHere', @inbound_publish_1.message
    assert_equal 'MessageHere', @inbound_publish_2.message
  end

  def test_encode_flags
    assert_equal 0b0000, @outbound_publish_1.flags
    assert_equal 0b1011, @outbound_publish_2.flags
  end

  def test_encode_message
    assert_equal "\x00\x04helpSOS", @outbound_publish_1.encode
    assert_equal "\x00\x04help\x00\x05SOS", @outbound_publish_2.encode
  end
end

class PubackPacketTest < MiniTest::Test
  def test_decode
    puback = PubackPacket.new.decode "\x00\xFF".to_stream
    assert_equal puback.packet_id, 0xFF
  end

  def test_encode
    puback = PubackPacket.new packet_id: 9
    assert_equal puback.encode, "\x00\x09"
  end
end
