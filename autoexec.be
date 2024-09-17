#-
 - Example of GGreg20_V3 driver written in Berry
 - Copyright IoT-devices, LLC - Kyiv - Ukraine - 2022
 - Note. You may additionaly use tasmota.cmd('counter1 0') to reset counter1
 -#
 
import string
var ctr = 0
var cur_ctr = 0
var cpm = 0
var ma5_pointer = 1
var ma5_val = 0
ma5 = {}

class GGREG20_V3 : Driver
  var st, fn
  var num_ctr_val
  var ctr_val
  var st_ctr_val
  var ctr

#  print(tasmota.read_sensors())
  
  def read_power()
    import string
    var st = number(string.find(tasmota.read_sensors(), "C1")+4)
    var fn = number(string.find(tasmota.read_sensors(), "ESP32")-4)
    var i = st
    var ctr_val = ''
    var ma5_sum = 0
    while i <= fn do ctr_val = ctr_val + tasmota.read_sensors()[i]; i = i + 1 end end
    if ctr == 0 
      self.st_ctr_val = number(ctr_val); 
      cur_ctr = self.st_ctr_val; 
      ctr = ctr + 1 
    end
    if ctr == 60 
      self.st_ctr_val = number(ctr_val); 
      cur_ctr = self.st_ctr_val; 
      ma5[ma5_pointer] = self.num_ctr_val
      var j = 1
      while j <= size(ma5) do ma5_sum = ma5_sum + ma5[j]; j = j + 1 end end
      ma5_val = ma5_sum / size(ma5)
      if ma5_pointer <= 4 
        ma5_pointer = ma5_pointer + 1 else ma5_pointer = 1 
      end; 
      ctr = 0 
    end

    cur_ctr = number(ctr_val)
    cpm = cur_ctr - self.st_ctr_val
    self.num_ctr_val = cpm * 0.0054
    return self.num_ctr_val; self.st_ctr_val
  end

  #- trigger a read every second -#
  def every_second()
    self.read_power()
    ctr = ctr + 1
  end

  #- display sensor value in the web UI -#
  def web_sensor()
      import string
      var msg = string.format(
                "{s}GGreg20_V3 cpm{m}%i CPM{e}"..
                "{s}GGreg20_V3 power{m}%1.3f uSv/h{e}".. 
                "{s}GGreg20_V3 ma5{m}%1.3f uSv/h{e}", 
                cpm, self.num_ctr_val, ma5_val)
      tasmota.web_send_decimal(msg)
  end

  #- add sensor value to teleperiod -#
  def json_append()
      import string
      var power = self.num_ctr_val
      var msg = string.format(",\"GGreg20_V3\":{\"cpm\":%i,\"power\":%1.3f,\"power ma5\":%1.3f}", cpm, power, ma5_val)
      tasmota.response_append(msg)
  end

end
GGREG20_V3 = GGREG20_V3()
tasmota.add_driver(GGREG20_V3)