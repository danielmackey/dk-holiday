colors = require 'colors'
io = require 'socket.io-client'
socket = io.connect 'http://localhost'


socket.on 'action assignment', (job) ->
  socket.emit 'right now', job
  console.log "#{"✓ ".green} ##{job.data.event.rainbow} by @#{job.data.handle.cyan}"


buffer = []

process = -> if buffer.length > 0 then arduino buffer.shift()

socket = (job) ->
  buffer.push job

arduino = (job) ->
  console.log job

socket 'foo'
socket 'bar'
socket 'baz'
socket 'foo'
socket 'bar'
socket 'baz'

setInterval process, 5000

