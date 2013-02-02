# encoding: utf-8
module Aloha
  
  class AnotherSameData < StandardError; end
  
  class AlohaUsb
    def initialize(port_name)
      @serial_port = SerialPort.new(port_name, 9600, 7, 1, SerialPort::EVEN)
      @serial_port.flow_control = (SerialPort::HARD | SerialPort::SOFT)
      
      @last_checked = 0
    end
    
    def push
      begin
        line = @serial_port.gets(Aloha.to_7bit_even_parity(Aloha::ETX))
        bytes = line.bytes.to_a
        bytes.shift #STX
        bytes.pop   #ETX
        
        caller_information = Aloha.from_7bit_even_parity(bytes)
        acknowledged
        if Time.now.to_i <= @last_checked
          raise AnotherSameData.new #ACKの送信がうまく行かない場合がある
        else
          @last_checked = Time.now.to_i + 2
        end
        
        month   = caller_information[0..1]
        day     = caller_information[2..3]
        weekday = caller_information[4]
        hour    = caller_information[5..6]
        minuite = caller_information[7..8]
        number  = caller_information[9..-1]

        time = Time.parse("#{Date.today.year}/#{month}/#{day} #{hour}:#{minuite}:00")

        number  = case number
        when Aloha::NOTIFICATION_HIDDEN
          :notification_hidden
        when Aloha::OUT_OF_SERVICE_AREA, Aloha::OUT_OF_SERVICE
          :out_of_service_area
        when Aloha::PUBLIC_PHONE
          :public_phone
        when Aloha::UNKNOWN_ERROR
          :unknown_error
        else
          number
        end

        [time, number]
      
      rescue AnotherSameData
        retry
      rescue ParityError
        not_acknowledged
        retry
      rescue => ex
        class << ex
          attr_accessor :aloha_info
        end
        
        ex.aloha_info = {
          :line               => line,
          :caller_information => caller_information
        }
        raise ex
      end
    end
    
    def quit
      @serial_port.close
    end
    
    
  private
    def acknowledged
      timeout(1){ while sp.cts() == 0; end }
    rescue
    ensure
      @serial_port.print(Aloha.to_7bit_even_parity(Aloha::ACK))
    end
    
    def not_acknowledged
      timeout(1){ while sp.cts() == 0; end }
    rescue
    ensure
      @serial_port.print(Aloha.to_7bit_even_parity(Aloha::NAK))
    end
  end
end
