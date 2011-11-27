Socket = require 'socket'

module.exports = App =
  init: () ->
    events = new Socket()
    events.init()
