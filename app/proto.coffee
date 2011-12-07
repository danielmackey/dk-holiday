express = require 'express'
SerialPort = require('serialport').SerialPort
arduino = require 'arduino'
#board = arduino.connect('/dev/tty.usbmodemfd131') # laptop
board = arduino.connect('/dev/tty.usbmodem1d11') #towe
connect = require 'connect'
colors = require 'colors'
app = express.createServer()
port = 1112
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


app.configure () ->
  app.use app.router
  app.use express.static "#{__dirname}/public"
  app.get '/on/:id', (req, res) ->
    board.digitalWrite req.params.id, ledState = arduino.HIGH
    console.log "turning #{req.params.id} on"
    res.send "turning #{req.params.id} on"
  app.get '/off/:id', (req, res) ->
    board.digitalWrite req.params.id, ledState = arduino.LOW
    console.log "turning #{req.params.id} off"
    res.send "turning #{req.params.id} off"
  app.get '/holicray', (req, res) -> 
    pins = [2..7]
    pins.forEach (pin, i) ->
      board.digitalWrite pin, ledState = arduino.HIGH
    console.log "holicray on"
    res.send "holiCRAY"
  app.get '/holidull', (req, res) ->
    pins = [2..7]
    pins.forEach (pin, i) ->
      board.digitalWrite pin, ledState = arduino.LOW
    console.log "holicray off, so dull"
    res.send "holiDULL"

app.listen port


