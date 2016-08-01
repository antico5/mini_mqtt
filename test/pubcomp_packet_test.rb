require 'test_helper'

class PubcompPacketTest < MiniTest::Test
  def test_decode
    pubcomp = PubcompPacket.new.decode "\x00\xFF".to_stream
    assert_equal pubcomp.packet_id, 0xFF
  end

  def test_encode
    pubcomp = PubcompPacket.new packet_id: 9
    assert_equal pubcomp.encode, "\x00\x09"
  end
end
