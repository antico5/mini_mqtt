require 'test_helper'

class ConnectPacketTest < MiniTest::Test
  def test_encode_with_all_params
    packet = ConnectPacket.new user: 'arman',
                               password: 'secret',
                               client_id: 'abc',
                               will_message: 'I am dead',
                               will_topic: 'last_will',
                               will_retain: false,
                               will_qos: 0,
                               clean_session: true,
                               keep_alive: 20
    encoded = packet.encode
    assert_equal "\x00\x04MQTT", encoded[0..5]
    assert_equal "\x04", encoded[6]
    assert_equal [0xc6], encoded[7].bytes
    assert_equal "\x00\x14", encoded[8..9]
    assert_equal "\x00\x03abc", encoded[10..14]
    assert_equal "\x00\x09last_will", encoded[15..25]
    assert_equal "\x00\x09I am dead", encoded[26..36]
    assert_equal "\x00\x05arman", encoded[37..43]
    assert_equal "\x00\x06secret", encoded[44..-1]
  end
end
