require 'test_helper'

class PubrelPacketTest < MiniTest::Test
  def test_decode
    pubrel = PubrelPacket.new.decode "\x00\xFF".to_stream
    assert_equal pubrel.packet_id, 0xFF
  end

  def test_encode_and_flags
    pubrel = PubrelPacket.new packet_id: 9
    assert_equal pubrel.encode, "\x00\x09"
    assert_equal 0b0010, pubrel.flags
  end

end
