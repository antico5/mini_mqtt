require 'test_helper'
require 'socket'

class ClientTest < MiniTest::Test
  def setup
    @client = Client.new host: 'localhost', port: 1883, keep_alive: 5,
      client_id: 'myclient'
  end

  def test_mosquitto_server_is_running
    socket = TCPSocket.new 'localhost', 1883
    assert !socket.closed?
    socket.close
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
    @client.clean_session = false
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
end

