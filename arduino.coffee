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

#initialize the digital pin as an output.
#board.pinMode ledPin, arduino.OUTPUT
#board.pinMode ledPin, ledState

socket = io.connect 'http://dk-holiday.herokuapp.com/arduino'
socket.on 'action assignment', (job) ->
  switch job.data.hashtag
    when "snow"
      pin = 1
      time = 5000
    when "lights"
      pin = 2
      time = 5000

  #board.digitalWrite pin, ledState = arduino.HIGH # on
  #setTimeout board.digitalWrite pin, ledState = arduino.LOW, time # off

  console.log "#{"✓ ".green} #{job.data.hashtag.rainbow} by #{job.data.handle.cyan}"
  socket.emit 'action complete', job
