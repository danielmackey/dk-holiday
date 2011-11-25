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

#initialize the digital pins as an output.
#board.pinMode 0, arduino.OUTPUT
#board.pinMode 0, ledState
#board.pinMode 1, arduino.OUTPUT
#board.pinMode 1, ledState
#board.pinMode 2, arduino.OUTPUT
#board.pinMode 2, ledState
#board.pinMode 3, arduino.OUTPUT
#board.pinMode 3, ledState
#board.pinMode 4, arduino.OUTPUT
#board.pinMode 4, ledState
#board.pinMode 5, arduino.OUTPUT
#board.pinMode 5, ledState
#board.pinMode 6, arduino.OUTPUT
#board.pinMode 6, ledState
#board.pinMode 7, arduino.OUTPUT
#board.pinMode 7, ledState
#board.pinMode 8, arduino.OUTPUT
#board.pinMode 8, ledState
#board.pinMode 9, arduino.OUTPUT
#board.pinMode 9, ledState
#board.pinMode 10, arduino.OUTPUT
#board.pinMode 10, ledState
#board.pinMode 11, arduino.OUTPUT
#board.pinMode 11, ledState
#board.pinMode 12, arduino.OUTPUT
#board.pinMode 12, ledState
#board.pinMode 13, arduino.OUTPUT
#board.pinMode 13, ledState

socket = io.connect 'http://localhost:1110/'

socket.on 'action assignment', (job) ->
  switch job.data.hashtag
    when "snow"
      pin = 1
      time = 5000
    when "lights"
      pin = 13
      time = 5000
    when "train"
      pin = 3
      time = 5000
    when "discoball"
      pin = 4
      time = 10000
    when "fan"
      pin = 5
      time = 10000

  #board.digitalWrite pin, ledState = arduino.HIGH # on
  #setTimeout(board.digitalWrite(pin, ledState = arduino.LOW), time) # off

  console.log "#{"✓ ".green} #{job.data.hashtag.rainbow} by #{job.data.handle.cyan}"
  socket.emit 'action complete', job
