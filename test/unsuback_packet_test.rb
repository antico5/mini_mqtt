require 'test_helper'

class UnsubackPacketTest < MiniTest::Test
  def test_decode
    packet = UnsubackPacket.new.decode "\x00\xFF".to_stream
    assert_equal packet.packet_id, 0xFF
  end
end
