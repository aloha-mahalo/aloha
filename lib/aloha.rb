# encoding: utf-8
require "aloha/version"
require "date"
require "time"
require "serialport"
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

require "aloha/aloha_usb"

module Aloha
  
  class ParityError < StandardError; end
  
  STX = 0x02.chr.freeze
  ETX = 0x03.chr.freeze
  ACK = 0x06.chr.freeze
  NAK = 0x15.chr.freeze
  BIT_MASK = 0x7f.freeze  #"01111111"
  
  #http://www.nikko-ew.co.jp/file/faq_usb.pdf
  # 非通知「P」、表示圏外「O又はS」、公衆電話「C」、エラー(-E-)「E」
  NOTIFICATION_HIDDEN = 'P'.freeze
  OUT_OF_SERVICE_AREA = 'O'.freeze
  OUT_OF_SERVICE      = 'S'.freeze
  UNKNOWN_ERROR       = "E".freeze
  PUBLIC_PHONE        = 'C'.freeze
  
  class << self
    def to_7bit_even_parity(message)
      message.chars.collect do |char|
        #例）7の場合
        #偶数パリティなので立っているビット数が奇数の場合、8ビット目=128を加える
        #10000000   = 128
        #00000111   = 7
        #--------
        #10000111   = 135
        #
        #http://www.ruby-lang.org/ja/old-man/html/pack_A5C6A5F3A5D7A5ECA1BCA5C8CAB8BBFACEF3.html
        
        char_code = char.ord
        char_code = char_code ^ 128 if char.ord.to_s(2).count("1").odd?
        char_code.chr
      end.join
    end
    
    def from_7bit_even_parity(bytes)
      #例）7の場合
      #偶数パリティが8ビット目にあり、これを除去する為にビットマスクで足す
      #10000111   = 135
      #01111111   = 127
      #--------
      #00000111   = 7
      #
      bytes.collect do |decimal|
        raise ParityError.new("broken data (odd found)") if decimal.to_s(2).count("1").odd?
        
        (decimal & BIT_MASK).chr
      end.join.strip
    end
    
    def wait_for_caller_infomation(port_name, device_name = :aloha_usb)
      device = "Aloha::#{device_name.to_s.camelize}".constantize.new(port_name)
      
      loop do
        yield device.push
      end
      
    ensure
      device.quit if device.present?
    end
  end
end