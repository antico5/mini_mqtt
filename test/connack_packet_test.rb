require 'test_helper'

class ConnackPacketTest < MiniTest::Test
  def test_decode_accepted_connection
    packet = ConnackPacket.new
    packet.decode "\x01\x00".to_stream
    assert packet.session_present?
    assert packet.accepted?
  end

  def test_decode_refused_connection
    packet = ConnackPacket.new
    packet.decode "\x00\x04".to_stream
    assert_equal false, packet.session_present?
    assert_equal false, packet.accepted?
    assert_match /bad username or password/, packet.error_message
  end
end
