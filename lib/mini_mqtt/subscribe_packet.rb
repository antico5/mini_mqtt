module MiniMqtt
  class SubscribePacket < Packet
    attr_accessor :packet_id, :topics
    register_packet_type 8

    def initialize params = {}
      @topics = params[:topics]
    end

    def flags
      0b0010
    end

    def build_variable_header
      @packet_id ||= new_packet_id
      ushort @packet_id
    end

    def build_payload
      @topics.map do |topic, qos|
        mqtt_utf8_encode(topic) + uchar(qos)
      end.join
    end
  end
end
