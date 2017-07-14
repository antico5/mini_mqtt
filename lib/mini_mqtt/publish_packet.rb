module MiniMqtt
  class PublishPacket < Packet
    attr_accessor :dup, :qos, :retain, :packet_id, :topic, :message
    register_packet_type 3

    def handle_flags flags
      @dup = flags & 0b1000 != 0
      @qos = (flags & 0b0110) >> 1
      @retain = flags & 0b0001 != 0
    end

    def read_variable_header
      @topic = read_mqtt_encoded_string @stream
      if @qos > 0
        @packet_id = read_ushort @stream
      end
    end

    def read_payload
      @message = @stream.read
    end

    def initialize params = {}
      @topic = params[:topic] || ""
      @message = params[:message] || ""
      @qos = params[:qos] || 0
      @dup = params[:dup] || false
      @retain = params[:retain] || false
      @packet_id = params[:packet_id]
    end

    def flags
      flags = 0
      flags |= 0b0001 if @retain
      flags |= qos << 1
      flags |= 0b1000 if @dup
      flags
    end

    def build_variable_header
      header = mqtt_utf8_encode @topic
      if @qos > 0
        @packet_id ||= new_packet_id
        header << ushort(@packet_id)
      end
      header
    end

    def build_payload
      @message
    end
  end
end
