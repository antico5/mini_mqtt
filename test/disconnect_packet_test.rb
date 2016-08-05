require 'test_helper'

class DisconnectPacketTest < MiniTest::Test
  def test_encode
    packet = DisconnectPacket.new
    assert_equal "", packet.encode
  end

  def test_flags
    packet = DisconnectPacket.new
    assert_equal 0, packet.flags
  end
end
