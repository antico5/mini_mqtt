$:.unshift File.dirname __FILE__
require 'minitest/autorun'
require 'pry'
require 'packet_reader'
require 'packet'


class TestPacketReader < Minitest::Test
  def setup
    @socket = StringIO.new
    connect_packet_bytes = "\x10\x00"
    unsubscribe_packet_bytes = "\xa2\x05topic"
    @socket.write connect_packet_bytes
    @socket.write unsubscribe_packet_bytes
    @socket.rewind
  end

  def test_get_packet
    reader = PacketReader.new @socket

    packet = reader.get_packet
    assert_equal ConnectPacket, packet.class
    assert_equal 0b0000, packet.flags
    assert_equal "", packet.body

    packet = reader.get_packet
    assert_equal UnsubscribePacket, packet.class
    assert_equal 0b0010, packet.flags
    assert_equal "topic", packet.body
  end
end

