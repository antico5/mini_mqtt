require 'test_helper'

class PubrecPacketTest < MiniTest::Test
  def test_decode
    pubrec = PubrecPacket.new.decode "\x00\xFF".to_stream
    assert_equal pubrec.packet_id, 0xFF
  end

  def test_encode
    pubrec = PubrecPacket.new packet_id: 9
    assert_equal pubrec.encode, "\x00\x09"
  end
end
