require 'test_helper'

class PingPacketTest < MiniTest::Test
  def test_pingreq_packet
    packet = PingreqPacket.new
    assert_equal "", packet.encode
  end

  def test_pingresp_packet
    packet = PingrespPacket.new.decode ""
    assert packet
  end
end
