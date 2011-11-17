express = require 'express'
SerialPort = require('serialport').SerialPort
arduino = require 'arduino'
#board = arduino.connect('/dev/tty.usbmodemfa131')
connect = require 'connect'
colors = require 'colors'
app = express.createServer()
port = 1112
io = require 'socket.io-client'

# Arduino config
ledState = arduino.LOW
ledPin = 13

#initialize the digital pin as an output.
#board.pinMode ledPin, arduino.OUTPUT
#board.pinMode ledPin, ledState

socket = io.connect 'http://localhost:1110/arduino'
socket.on 'action assignment', (job) ->
  if job.data.hashtag is "snow"
    #board.digitalWrite ledPin, ledState = arduino.HIGH # set the LED on
  else
    #board.digitalWrite ledPin, ledState = arduino.LOW # set the LED off

  console.log "#{"✓ ".green} #{job.data.hashtag.rainbow} by #{job.data.handle.cyan}"
  socket.emit 'action complete', job
