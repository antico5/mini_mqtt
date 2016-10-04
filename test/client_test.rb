require 'test_helper'
require 'socket'
require 'timeout'

class ClientTest < MiniTest::Test
  TEST_SERVER = 'test.mosquitto.org'

  def setup
    @client = Client.new host: TEST_SERVER
  end

  def test_mosquitto_server_is_running
    begin
      socket = TCPSocket.new TEST_SERVER, 1883
      socket.close
    rescue
      puts "There should be a mosquitto server running to run tests."
    end
  end

  def test_connect_and_disconnect
    @client.connect
    assert @client.connected?
    @client.disconnect
    refute @client.connected?
  end

  def test_subscribe_and_publish
    @client.connect
    @client.subscribe '/mini_mqtt/test'
    @client.publish '/mini_mqtt/test', 'hi'
    msg = @client.get_message
    assert_equal '/mini_mqtt/test', msg.topic
    assert_equal 'hi', msg.message
    @client.disconnect
  end

  def test_subscribe_multiple_topics
    @client.connect
    @client.subscribe '/mini_mqtt/test1', '/mini_mqtt/test2'
    @client.publish '/mini_mqtt/test1', 'message_1'
    @client.publish '/mini_mqtt/test2', 'message_2'
    expected = ['message_1', 'message_2']
    @client.get_messages do |message|
      assert_equal expected.shift, message
      break if expected.empty?
    end
    @client.disconnect
  end

  def test_unsubscribe
    @client.connect
    @client.subscribe '/mini_mqtt/test'
    @client.unsubscribe '/mini_mqtt/test'
    @client.publish '/mini_mqtt/test', 'hi'
    assert_raises(Timeout::Error) do
      Timeout::timeout(1) do
        @client.get_message
      end
    end
    @client.disconnect
  end

  def test_retain_message
    @client.connect
    message_to_retain = rand.to_s
    @client.publish '/mini_mqtt/retain', message_to_retain, retain: true
    @client.subscribe '/mini_mqtt/retain'
    assert_equal message_to_retain, @client.get_message.message
    @client.disconnect
  end

  def test_clean_session
    @client = MiniMqtt::Client.new host: TEST_SERVER, clean_session: false
    @client.connect
    @client.subscribe '/mini_mqtt/test'
    @client.disconnect
    @client.connect
    @client.publish '/mini_mqtt/test', 'hello'
    assert_equal 'hello', @client.get_message.message
    @client.disconnect
  end

  def test_last_will
    @client2 = MiniMqtt::Client.new host: TEST_SERVER
    @client2.connect
    @client2.subscribe 'mini_mqtt/last_will'
    sleep 3 # wait for suback to come back
    @client.connect will_topic: 'mini_mqtt/last_will', will_message: 'help!!'
    # abruptly close connection by closing socket.
    @client.instance_variable_get(:@socket).close
    assert_equal 'help!!', @client2.get_message.message
    @client2.disconnect
  end

  def test_last_will_with_retain
    will_msg = rand.to_s
    @client.connect will_topic: 'mini_mqtt/last_will_retain', will_message: will_msg,
      will_retain: true
    assert @client.connected?
    @client.instance_variable_get(:@socket).close
    @client.connect
    @client.subscribe 'mini_mqtt/last_will_retain'
    assert_equal will_msg, @client.get_message.message
    @client.disconnect
  end

  def test_qos_1
    @client.connect
    @client.subscribe '/mini_mqtt/topic_qos' => 1
    @client.publish '/mini_mqtt/topic_qos', 'msg', qos: 1
    msg = @client.get_message
    assert_equal '/mini_mqtt/topic_qos', msg.topic
    assert_equal 'msg', msg.message
    assert_equal 1, msg.qos
    @client.disconnect
  end
end

