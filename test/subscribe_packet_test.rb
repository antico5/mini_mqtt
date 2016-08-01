require 'test_helper'

class SubscribePacketTest < MiniTest::Test
  def setup
    @packet = SubscribePacket.new topics: { 'topic1' => 0, 'topic2' => 1 }
    @packet2 = SubscribePacket.new topics: { 'topic3' => 0 }
  end

  def test_flags
    assert_equal 0b0010, @packet.flags
  end

  def test_packet_ids
    @packet.encode
    @packet2.encode
    assert @packet.packet_id > 0
    assert @packet2.packet_id > @packet.packet_id
  end

  def test_encode
    @packet.packet_id = 1
    @packet2.packet_id = 2
    assert_equal "\x00\x01\x00\x06topic1\x00\x00\x06topic2\x01", @packet.encode
    assert_equal "\x00\x02\x00\x06topic3\x00", @packet2.encode
  end

end
