require 'test_helper'

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
