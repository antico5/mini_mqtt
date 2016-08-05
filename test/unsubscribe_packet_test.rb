require 'test_helper'

class UnsubscribePacketTest < MiniTest::Test
  def setup
    @packet = UnsubscribePacket.new topics: ['topic1', 'topic2']
  end

  def test_flags
    assert_equal 0b0010, @packet.flags
  end

  def test_packet_id
    @packet.encode
    assert @packet.packet_id > 0
  end

  def test_encode
    @packet.packet_id = 1
    assert_equal "\x00\x01\x00\x06topic1\x00\x06topic2", @packet.encode
  end

end
