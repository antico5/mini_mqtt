require 'test_helper'
require 'socket'
require 'timeout'

class ClientTest < MiniTest::Test
  def setup
    @client = Client.new host: 'localhost'
  end

  def test_mosquitto_server_is_running
    begin
      socket = TCPSocket.new 'localhost', 1883
      socket.close
    rescue
      puts "You should have mosquitto server running to run integration
      tests. Try sudo apt-get install mosquitto."
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
    @client.subscribe '/test'
    @client.publish '/test', 'hi'
    @client.get_message do |msg, topic|
      assert_equal '/test', topic
      assert_equal 'hi', msg
    end
    @client.disconnect
  end

  def test_subscribe_multiple_topics
    @client.connect
    @client.subscribe '/test1', '/test2'
    @client.publish '/test1', 'message_1'
    @client.publish '/test2', 'message_2'
    received = []
    2.times do
      @client.get_message { |msg| received << msg }
    end
    assert_equal ['message_1', 'message_2'], received
  end

  def test_unsubscribe
    @client.connect
    @client.subscribe '/test'
    @client.unsubscribe '/test'
    @client.publish '/test', 'hi'
    assert_raises(Timeout::Error) do
      Timeout::timeout(1) do
        @client.get_message do |msg, topic|
        end
      end
    end
    @client.disconnect
  end

  def test_retain_message
    @client.connect
    message_to_retain = rand.to_s
    @client.publish '/retain', message_to_retain, retain: true
    @client.subscribe '/retain'
    @client.get_message do |msg|
      assert_equal message_to_retain, msg
    end
    @client.disconnect
  end

  def test_clean_session
    @client = MiniMqtt::Client.new host: 'localhost', clean_session: false
    @client.connect
    @client.subscribe '/test'
    @client.disconnect
    @client.connect
    @client.publish '/test', 'hello'
    @client.get_message do |msg|
      assert_equal 'hello', msg
    end
    @client.disconnect
  end

  def test_last_will
    @client2 = MiniMqtt::Client.new host: 'localhost'
    @client2.connect
    @client2.subscribe 'last_will'
    sleep 1 # wait for suback to come back
    @client.connect will_topic: 'last_will', will_message: 'help!!'
    # abruptly close connection by closing socket.
    @client.instance_variable_get(:@socket).close
    @client2.get_message do |msg|
      assert_equal 'help!!', msg
    end
    @client2.disconnect
  end

  def test_last_will_with_retain
    will_msg = rand.to_s
    @client.connect will_topic: 'last_will_retain', will_message: will_msg,
      will_retain: true
    assert @client.connected?
    @client.instance_variable_get(:@socket).close
    @client.connect
    @client.subscribe 'last_will_retain'
    @client.get_message do |msg|
      assert_equal msg, will_msg
    end
    @client.disconnect
  end
end

