twitter = require 'ntwitter'
Worker = require "#{__dirname}/worker"

#
# ##Twitter Streaming
#
#   - Grab tweets @designkitchen
#
module.exports = Stream =
  users: [
    'designkitchen'
    'holiduino'
  ]

  keys: # TODO: Get production keys with @designkitchen account
    consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
    consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
    access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
    access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'

  init: (@app, @jobs, @logger) ->
    @openSocket()
    @openTwitter()
    Worker.init @jobs, @logger

  openSocket: ->
    #
    # #### Websocket
    #
    #   - Identify each client on connection and disconnection
    #   - Process jobs only if arduino is connected
    #
    io = require('socket.io').listen @app
    io.set 'log level', 1
    io.set 'authorization', (handshakeData, callback) ->
      callback null, true

    ws = io.of('/arduino').on 'connection', (socket) =>
      @socket = socket
      Worker.rollCall 'present', socket

      socket.on 'disconnect', => Worker.rollCall 'absent', socket
      socket.on 'current', (job) -> socket.broadcast.emit 'right now', job
      Worker.start socket


  openTwitter: ->
    api = new twitter @keys
    api.stream 'user', track:@users, (stream) =>
      @logger.twitter '', 'following':@users

      stream.on 'data', (tweet) =>
        unless tweet.friends? #The first stream message is an array of friend IDs, ignore it
          @logger.save "@#{tweet.user.screen_name}: #{tweet.text}"
          Worker.assign tweet
          if @socket? then @socket.emit 'new tweet', tweet
