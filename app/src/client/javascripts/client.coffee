Socket = require 'socket'



#
# ####Initialize the Client App
#
#   - Open a websocket for communication with the server
#
module.exports = Client =
  init: () ->
    events = new Socket()
    events.init()
