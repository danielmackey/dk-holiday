SerialPort = require('serialport').SerialPort
arduino = require 'arduino'
#board = arduino.connect('/dev/tty.usbmodemfa131')
board = arduino.connect('/dev/tty.usbmodem1d11') #tower
colors = require 'colors'
io = require 'socket.io-client'

# Arduino config
ledState = arduino.LOW

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

connected = false
timeout = null

socket = io.connect 'http://50.57.133.51'

socket.on 'connect', -> 
  connected = true
  console.log 'connected'
  clearTimeout timeout

socket.on 'disconnect', -> 
  connected = false
  console.log 'disconnected, reconnecting...'
  retryConnectOnFailure(10000)

socket.on 'connect_failed', ->
  connected = false
  console.log 'connection failed, reconnecting...'
  retryConnectOnFailure(10000)

retryConnectOnFailure = (retryInMilliseconds) ->
  timeout = setTimeout letsConnect, retryInMilliseconds

letsConnect = () ->
  unless connected then socket.reconnect()
  retryConnectOnFailure()

# actually connect
retryConnectOnFailure()

arduinoOff = (pin) -> 
  console.log "arduinOff #{pin}"
  board.writeDigital pin, arduino.LOW

# Receive a new job assignment from the server and push to the buffer array
socket.on 'action assignment', (job) ->
  socket.emit 'right now', job

  time = 9000

  switch job.data.event
    when 'the table lights dance.'
      board.digitalWrite 2, ledState = arduino.HIGH #on
      setTimeout(arduinoOff, time, 2) # off
    when 'the wall lights turn on.'
      board.digitalWrite 3, ledState = arduino.HIGH #on
      setTimeout(arduinoOff, time, 3)
    when 'the stars light up.'
      board.digitalWrite 4, ledState = arduino.HIGH #on
      setTimeout(arduinoOff, time, 4) #off
    when 'it snow up in here.'
      time = 5000
      board.digitalWrite 5, ledState = arduino.HIGH #on
      setTimeout(arduinoOff, time, 5) #off
    when 'the sirens go to town.'
      board.digitalWrite 6, ledState = arduino.HIGH #on
      setTimeout(arduinoOff, time, 6) #off
    when 'the wacky tube man dance.'
      board.digitalWrite 7, ledState = arduino.HIGH #on
      setTimeout(arduinoOff, time, 7) #off
    when 'it Holicray!'
      board.digitalWrite 2, arduino.HIGH # on
      board.digitalWrite 3, arduino.HIGH # on
      board.digitalWrite 4, arduino.HIGH # on
      board.digitalWrite 5, arduino.HIGH # on
      board.digitalWrite 6, arduino.HIGH # on
      board.digitalWrite 7, arduino.HIGH # on
      setTimeout(arduinoOff, time, 2) #off
      setTimeout(arduinoOff, time, 3) #off
      setTimeout(arduinoOff, time, 4) #off
      setTimeout(arduinoOff, time, 5) #off
      setTimeout(arduinoOff, time, 6) #off
      setTimeout(arduinoOff, time, 7) #off

  console.log "@#{job.data.handle.cyan} just made #{job.data.event.rainbow}"
