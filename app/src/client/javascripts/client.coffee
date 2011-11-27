Socket = require 'socket'

module.exports = Client =
  init: () ->
    events = new Socket()
    events.init()
