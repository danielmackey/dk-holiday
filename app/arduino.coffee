SerialPort = require('serialport').SerialPort
arduino = require 'arduino'
#board = arduino.connect('/dev/tty.usbmodemfa131')
board = arduino.connect('/dev/tty.usbmodem1d11') #tower
colors = require 'colors'
io = require 'socket.io-client'

# Arduino config
ledState = arduino.LOW

#initialize the digital pins as an output.
# initilaze the digital pins as an output
board.pinMode 2, arduino.OUTPUT
board.pinMode 2, ledState

board.pinMode 3, arduino.OUTPUT
board.pinMode 3, ledState

board.pinMode 4, arduino.OUTPUT
board.pinMode 4, ledState

board.pinMode 5, arduino.OUTPUT
board.pinMode 5, ledState

board.pinMode 6, arduino.OUTPUT
board.pinMode 6, ledState

board.pinMode 7, arduino.OUTPUT
board.pinMode 7, ledState

socket = io.connect 'http://50.57.133.51:5000'

socket.on 'action assignment', (job) ->
  socket.emit 'right now', job
  #board.digitalWrite pin, ledState = arduino.HIGH # on
  #setTimeout(board.digitalWrite(pin, ledState = arduino.LOW), time) # off

  console.log "@#{job.data.handle.cyan} just made #{job.data.event.rainbow}"
