$:.unshift File.join( __FILE__, "..", "..", "lib")
require 'pry'
require 'mini_mqtt'
require 'minitest/autorun'


class String
  def to_stream
    StringIO.new self
  end
end

class MiniTest::Test
  include MiniMqtt
end
