require 'test_helper'

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
