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

  time = 9000

  switch job.data.event
    when 'it snow'
      board.digitalWrite 2, ledState = arduino.HIGH #on
      setTimeout( board.digitalWrite( 2, ledState = arduino.LOW), time) # off
    when 'the lights on the tree blink'
      board.digitalWrite 3, ledState = arduino.HIGH #on
      setTimeout( board.digitalWrite( 3, ledState = arduino.LOW), time ) #off
    when 'the stars light up'
      board.digitalWrite 4, ledState = arduino.HIGH #on
      setTimeout( board.digitalWrite( 4, ledState = arduino.LOW), time ) #off
    when 'the discoball spin'
      board.digitalWrite 5, ledState = arduino.HIGH #on
      setTimeout( board.digitalWrite( 5, ledState = arduino.LOW), time ) #off
    when 'the wacky man dance'
      board.digitalWrite 6, ledState = arduino.HIGH #on
      setTimeout( board.digitalWrite( 6, ledState = arduino.LOW), time ) #off
    when 'holicray'
      board.digitalWrite 2, ledState = arduino.HIGH # on
      board.digitalWrite 3, ledState = arduino.HIGH # on
      board.digitalWrite 4, ledState = arduino.HIGH # on
      board.digitalWrite 5, ledState = arduino.HIGH # on
      board.digitalWrite 6, ledState = arduino.HIGH # on
      board.digitalWrite 7, ledState = arduino.HIGH # on
      setTimeout( board.digitalWrite( 2, ledState = arduino.LOW), time ) #off
      setTimeout( board.digitalWrite( 3, ledState = arduino.LOW), time ) #off
      setTimeout( board.digitalWrite( 4, ledState = arduino.LOW), time ) #off
      setTimeout( board.digitalWrite( 5, ledState = arduino.LOW), time ) #off
      setTimeout( board.digitalWrite( 6, ledState = arduino.LOW), time ) #off
      setTimeout( board.digitalWrite( 7, ledState = arduino.LOW), time ) #off

  console.log "@#{job.data.handle.cyan} just made #{job.data.event.rainbow}"


