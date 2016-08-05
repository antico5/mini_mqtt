module MiniMqtt
  class Session
    def initialize packet_handler
      @handler = packet_handler
    end

    def subscribe topic
      packet = SubscribePacket.new topics: {topic => 0}
      @handler.write_packet packet
    end

    def publish topic, message
      packet = PublishPacket.new topic: topic, message: message
      @handler.write_packet packet
    end
  end
end
