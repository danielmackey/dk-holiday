Stats = require './stats'
Client = require './client'

#
# ####Client Websocket
#
#   - Listen for the 'refresh stats' message
#   - Listen for the holicray events and then go cray
#
module.exports = class Socket
  constructor: () ->
    @openSocket()

  openSocket: ->
    client = io.connect '/'
    client.on 'refresh stats', (currentJob) ->
      Stats.newEvent()
      if currentJob?
        if currentJob.type is 'holicray' then Client.goCray()
