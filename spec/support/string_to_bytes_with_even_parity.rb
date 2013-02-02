# encoding: utf-8
module StringToBytesWithEvenParity
  
  def to_caller_infomation(line)
    Aloha.to_7bit_even_parity("#{Aloha::STX}#{line}#{Aloha::ETX}")
  end
    
end