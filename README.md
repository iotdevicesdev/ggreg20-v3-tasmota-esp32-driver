# GGreg20_V3 and ESP32 Tasmota Firmware driver
GGreg20_V3 Ionizing Radiation Detector powered SBM-20 GM tube with Generic ESP32 under Tasmota Firmware and Berry script driver example 

Hackaday Project Page: https://hackaday.io/project/183103-ggreg20v3-ionizing-radiation-detector

## Documentation
- Product description https://iot-devices.com.ua/en/product/ggreg20_v3-ionizing-radiation-detector-with-geiger-tube-sbm-20/
- Datasheet https://iot-devices.com.ua/wp-content/uploads/2021/11/ggreg20_v3-datasheet-eng.pdf

## Configuration Template

As an example, GPIO0 port as counter1 is used: 
```json
{"NAME":"ESP32-GGreg20","GPIO":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,1,1,1,1,1,0,0,1],"FLAG":0,"BASE":1}
```

## Tasmota Berry Script Code
The ggreg20_v3_drv.be code can be loaded manually with copy/paste, or stored in flash and loaded at startup in autoexec.be
```berry
#-
 - Example of GGreg20_V3 driver written in Berry
 - Copyright IoT-devices, LLC - Kyiv - Ukraine - 2022
 - License https://github.com/iotdevicesdev/ggreg20-v3-tasmota-esp32-driver/blob/main/LICENSE
 - Note. You may additionaly use tasmota.cmd('counter1 0') to reset counter1
 -#

import string
var ctr = 0
var cur_ctr = 0
var cpm = 0
var ma5_pointer = 1
var ma5_val = 0
var dose = 0
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
      dose = dose + (self.num_ctr_val * 0.00009)
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
                "{s}GGreg20_V3 dose{m}%1.4f uSv{e}"..
                "{s}GGreg20_V3 ma5{m}%1.3f uSv/h{e}", 
                cpm, self.num_ctr_val, dose, ma5_val)
      tasmota.web_send_decimal(msg)
  end

  #- add sensor value to teleperiod -#
  def json_append()
      import string
      var power = self.num_ctr_val
      var msg = string.format(",\"GGreg20_V3\":{\"cpm\":%i,\"power\":%1.3f,\"dose\":%1.4f,\"power ma5\":%1.3f}", cpm, power, dose, ma5_val)
      tasmota.response_append(msg)
  end

end
GGREG20_V3 = GGREG20_V3()
tasmota.add_driver(GGREG20_V3)
```

## Visualization
Following data is calculated by the GGreg20_V3 driver:
- CPM - SBM-20 counts per minute
- Ionizing Radiation Power, uSv/H
- Ionizing Radiation Dose counted from uptime, uSv
- Ionizing Radiation Power - A 5-minutes Moving Average

```json
{"Time":"2022-01-08T23:22:11","COUNTER":{"C1":6966},"ESP32":{"Temperature":53.3},"GGreg20_V3":{"cpm":25,"power":0.135,"dose":0.0020,"power ma5":0.181},"TempUnit":"C"}

```
and figured out by the Tasmota's Web UI:

![GGreg20_V3 Tasmota ESP32](https://github.com/iotdevicesdev/ggreg20-v3-tasmota-esp32-driver/blob/main/Tasmota_GGreg20_Dashboard-2022-01-08_220634.jpg)

## Buy GGreg_V3 Ionizing Radiation Detector Module
On Tindie: https://www.tindie.com/products/iotdev/ggreg20_v3-ionizing-radiation-detector/

IoT-devices Online Shop: https://iot-devices.com.ua/en/product/ggreg20_v3-ionizing-radiation-detector-with-geiger-tube-sbm-20/

## Watch demo video
- coming soon

IoT-devices YouTube Channel: https://www.youtube.com/channel/UCHpPOVVlbbdtYtvLUDt1NZw/videos
