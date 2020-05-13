require 'stringio'

module MiniMqtt
  class PacketHandler
    include BinHelper

    MAX_LENGTH_MULTIPLIER = 128 ** 3

    @@debug = false

    def self.enable_debug
      @@debug = true
    end

    def initialize stream
      @stream = stream
      @mutex = Mutex.new
    end

    def get_packet
      # First byte contains packet type and flags. 4 bits each.
      first_byte = @stream.readbyte
      packet_class = Packet.get_packet_class(first_byte >> 4)
      flags = first_byte & 0xf

      #Decode length using algorithm, and read packet body.
      length = decode_length @stream
      encoded_packet = @stream.read length
      log_in_packet packet_class, encoded_packet

      # Create appropiate packet instance and decode the packet body.
      packet_class.new.decode StringIO.new(encoded_packet), flags

    rescue StandardError => e
      log "Exception while receiving: #{ e.inspect }"
      @stream.close
    end

    def write_packet packet
      # Write type and flags, then encoded packet length, then packet
      @mutex.synchronize do
        type_and_flags = packet.class.packet_type_id << 4
        type_and_flags += packet.flags
        @stream.write uchar(type_and_flags)
        encoded_packet = packet.encode
        log_out_packet packet
        @stream.write encode_length(encoded_packet.bytesize)
        @stream.write encoded_packet
      end
    rescue StandardError => e
      log "Exception while receiving: #{ e.inspect }"
      @stream.close
    end

    private

    def encode_length length
      encoded = ""
      loop do
        encoded_byte = length % 128
        length = length / 128
        encoded_byte |= 128 if length > 0
        encoded << encoded_byte.chr
        break if length == 0
      end
      encoded
    end

    def decode_length stream
      length = 0
      multiplier = 1
      while encoded_byte = stream.readbyte
        length += (encoded_byte & 0x7f) * multiplier
        break if encoded_byte & 0x80 == 0
        multiplier *= 128
        raise "Malformed remaining length" if multiplier > MAX_LENGTH_MULTIPLIER
      end
      length
    end

    def log_in_packet type, message
      log "\nIN - #{ type } - #{ message.inspect }\n"
    end

    def log_out_packet packet
      log "\nOUT - #{ packet.class } - #{ packet.instance_variable_get :@packet_id } - #{ packet.encode.inspect }\n"
    end

    def log text
      if @@debug
        puts text
      end
    end
  end
end
