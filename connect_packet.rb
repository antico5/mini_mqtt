require 'packet'

class ConnectPacket < Packet
  def initialize options = {}
    @user = options[:user]
    @password = options[:password]
    @client_id = options[:client_id] || rand(1000000).to_s
    @will_message = options[:will_message]
    @will_topic = options[:will_topic]
    @will_retain = options[:will_retain]
    @will_qos = options[:will_qos] || 0
    @clean_session = options.fetch :clean_session, true
    @keep_alive = options[:keep_alive] || 15
  end

  def build_variable_header
    # Protocol name
    header = ushort(4) # length of name
    header << 'MQTT' # name
    # Protocol level
    header << uchar(4)
    # Flags
    byte = flag_byte [ @user, @password, @will_retain, nil, nil,
                          @will_message, @clean_session, nil]
    byte |= @will_qos << 3
    header << uchar(byte)
    #Keepalive
    header << ushort(@keep_alive)
    header
  end

  def build_payload
    payload = ""
    payload << mqtt_utf8_encode(@client_id)
    if @will_message
      payload << mqtt_utf8_encode(@will_topic)
      payload << mqtt_utf8_encode(@will_message)
    end
    payload << mqtt_utf8_encode(@user) if @user
    payload << mqtt_utf8_encode(@password) if @password
    payload
  end
end
