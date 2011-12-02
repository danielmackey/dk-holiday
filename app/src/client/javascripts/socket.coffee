Stats = require './stats'

#
# ####Client Websocket
#
#   - Listen for the 'new event' message
#   - Listen for the 'tally mark' message and confirm reception
#
module.exports = class Socket
  constructor: () ->
    @openSocket()

  openSocket: ->
    client = io.connect '/arduino'
    client.on 'new event', -> Stats.newEvent()
