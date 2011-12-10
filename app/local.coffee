colors = require 'colors'
io = require 'socket.io-client'
socket = io.connect 'http://localhost:5000'


socket.on 'action assignment', (job) ->
  socket.emit 'right now', job
  console.log "#{"✓ ".green} ##{job.data.event.rainbow} by @#{job.data.handle.cyan}"
