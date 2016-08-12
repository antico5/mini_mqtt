require 'test_helper'
require 'socket'

class ClientTest < MiniTest::Test
  def setup
    @client = Client.new host: 'localhost', port: 1883, keep_alive: 5,
      client_id: 'myclient', clean_session: false
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
end

