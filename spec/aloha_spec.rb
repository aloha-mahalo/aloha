# encoding: utf-8
require 'spec_helper'
require "aloha"
require "support/string_to_bytes_with_even_parity"

describe Aloha do
  include StringToBytesWithEvenParity
  
  before(:each) do
    @pipe = IO.popen("cat", "r+")
    @pipe.should_receive(:flow_control=).any_number_of_times.and_return(nil)
    SerialPort.should_receive(:new).any_number_of_times.and_return(@pipe)
  end
  
  it "should receive time and number" do
    @pipe.print to_caller_infomation("02013101008012345678")
    
    Timecop.freeze(Time.parse "2012/02/01 10:10:00") do
      Aloha.wait_for_caller_infomation("/dev/fake.usb") do |time, number|
        time.should == Time.parse("2012/02/01 10:10:00")
        number.should == "08012345678"
        break
      end
    end
  end
  
  it "should send ACK to aloha" do
    @pipe.print to_caller_infomation("02013101008012345678")
    
    Aloha.wait_for_caller_infomation("/dev/fake.usb") do |time, number|
      Aloha.from_7bit_even_parity(@pipe.getc.bytes.to_a).should == Aloha::ACK
      break
    end
  end
  
  it "should send NAK to aloha" do
    #１回目
    @pipe.print to_caller_infomation("02013101008012345678")
    Aloha.should_receive(:from_7bit_even_parity).and_raise(Aloha::ParityError)
    #NAKが送られるかチェック
    usb = Aloha::AlohaUsb.new("/dev/fake.usb")
    usb.should_receive(:not_acknowledged)
    Aloha::AlohaUsb.should_receive(:new).and_return(usb)
    
    
    #ループから脱出する用
    Aloha.should_receive(:from_7bit_even_parity).and_return("02013101008012345678")
    Thread.new do
      sleep 0.5
      @pipe.print to_caller_infomation("02013101008012345678")
    end
    
    Aloha.wait_for_caller_infomation("/dev/fake.usb") do |time, number|
      break
    end
  end
  
end