module BinHelper
  def uchar number
    [number].pack 'C'
  end

  def ushort number
    [number].pack 'n'
  end

  def flag_byte flags
    raise "flags must have 8 elements" unless flags.size == 8
    byte = 0
    flags.reverse.each_with_index do |flag, index|
      byte |= 1 << index if flag
    end
    byte
  end

  def mqtt_utf8_encode string
    ushort(string.length) + string
  end

end
