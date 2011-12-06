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
    client = io.connect '/'
    client.on 'refresh stats', ->
      console.log 'refresh stats'
      Stats.newEvent()
