require 'test_helper'

class SubackPacketTest < MiniTest::Test
  def test_decode
    packet = SubackPacket.new
    packet.decode "\x01\x00\x01\x00\x02".to_stream
    assert_equal 256, packet.packet_id
    assert_equal [1, 0, 2], packet.max_qos_accepted
  end
end
