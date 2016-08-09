require 'test_helper'

class ClientTest < MiniTest::Test
  def setup
    @client = Client.new host: 'localhost', port: 1883, keep_alive: 5,
      client_id: 'myclient', clean_session: false
  end

  def test_connect
    session = @client.connect
    assert session
    assert session.disconnect
  end
end

