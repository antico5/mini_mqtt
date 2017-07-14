module MiniMqtt
  class Packet
    include BinHelper

    @@last_packet_id = 0
    @@packet_classes = {}

    def decode stream, flags = 0
      @stream = stream
      handle_flags flags
      read_variable_header
      read_payload
      self
    end

    def encode
      build_variable_header + build_payload
    end

    def flags
      0b000
    end

    def self.packet_type_id
      @packet_type_id
    end

    def self.get_packet_class packet_type_id
      @@packet_classes[packet_type_id]
    end

    private

    def self.register_packet_type packet_type_id
      @packet_type_id = packet_type_id
      @@packet_classes[packet_type_id] = self
    end

    def new_packet_id
      @@last_packet_id += 1
      @@last_packet_id %= 65535
      1 + @@last_packet_id
    end

    def read_variable_header
    end

    def read_payload
    end

    def handle_flags flags
    end

    def build_variable_header
      ""
    end

    def build_payload
      ""
    end
  end

  module AckPacket
    attr_accessor :packet_id

    def initialize params = {}
      @packet_id = params[:packet_id]
    end

    def read_variable_header
      @packet_id = read_ushort @stream
    end

    def build_variable_header
      ushort @packet_id
    end
  end
end
