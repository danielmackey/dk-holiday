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
    #Client.goCray()

  openSocket: ->
    buffer = []
    process = -> if buffer.length > 0 then refresh buffer.shift()
    client = io.connect '/'

    refresh = (currentJob) ->
      Stats.newEvent()
      if currentJob.type is 'it Holicray!' then Client.goCray()

    client.on 'refresh stats', (currentJob) ->
      if currentJob? then buffer.push currentJob
      else Stats.getQueue()

    setInterval process, 5000
