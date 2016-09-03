require 'em-rubyserial'
require 'time' # needed for ruby1.9 on raspberry pi

EM.run do
  serial = EventMachine.open_serial("/dev/ttyACM0", 38400, 8)
  # show version information of your device
  # serial.send_data "V\r"
  serial.send_data "X21\r"

  chunks = []

  serial.on_data do |data|
    chunks << data

    line = chunks.join
    # puts chunks.inspect
    # if all the received stuff ends with a linebreak
    if line =~ /\n$/
      # puts line
      # stolen from how fhem parses the data
      # https://github.com/mhop/fhem-mirror/blob/master/fhem/FHEM/14_CUL_WS.pm#L146-L156
      
      # can also be K015292441F, find out what F means
      if line =~ /^K\d{9,10}\D?/
        temp = "#{line[6]}#{line[3]}.#{line[4]}".to_f
        hum  = "#{line[7]}#{line[8]}.#{line[5]}".to_f
        puts "{\"raw\": \"#{line.strip}\", \"temp\": #{temp}, \"hum\": #{hum}, \"created_at\": \"#{Time.now.iso8601}\"}"
        EM.stop_event_loop
      end
      chunks = []
    end
  end
end
