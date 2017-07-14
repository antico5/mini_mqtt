module MiniMqtt
  class UnsubscribePacket < Packet
    attr_accessor :packet_id, :topics
    register_packet_type 10

    def flags
      0b0010
    end

    def initialize params = {}
      @topics = params[:topics]
    end

    def build_variable_header
      @packet_id ||= new_packet_id
      ushort @packet_id
    end

    def build_payload
      @topics.map do |topic|
        mqtt_utf8_encode(topic)
      end.join
    end
  end
end
