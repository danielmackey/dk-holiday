express = require 'express'
SerialPort = require('serialport').SerialPort
arduino = require 'arduino'
board = arduino.connect('/dev/tty.usbmodemfa131')
app = express.createServer()
port = 1111

# Configure the server with stylus and stitch middleware
app.configure () ->
  app.use app.router
  app.use express.static "#{__dirname}/public"

  ## Routes
  app.get '/foo', (req, res) ->
    res.send "bar"

  app.get '/on', (req, res) ->
    board.pinMode 12, arduino.OUTPUT
    board.digitalWrite 12, arduino.HIGH
    res.send "on"

  app.get '/off', (req,res) ->
    board.pinMode 12, arduino.OUTPUT
    board.digitalWrite 12, arduino.LOW
    res.send "off"


# Start the server
app.listen port
console.log "Arduino server started on port: #{port}"
