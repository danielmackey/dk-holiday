twitter = require 'ntwitter'
Buffer = require './buffer'
Worker = require './worker'

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

  # #### Keep tabs on which clients are currently connected
  roll:
    browser:false
    arduino:false

  init: (@app, @jobs, @logger) ->
    @openSocket()
    @openTwitter()

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
      @rollCall 'present', socket

      socket.on 'disconnect', =>
        @rollCall 'absent', socket

      socket.on 'current', (job) ->
        socket.broadcast.emit 'right now', job

      # Proceed if arduino is connected
      if @isPresent 'arduino'
        Worker.processJobs socket, @jobs, @logger


  openTwitter: ->
    keys = # TODO: Get production keys with @designkitchen account
      consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
      consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
      access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
      access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'

    api = new twitter keys
    api.stream 'user', track:@users, (stream) =>
      @logger.twitter '', 'following':@users

      stream.on 'data', (tweet) =>
        unless tweet.friends?
          @save tweet #The first stream message is an array of friend IDs, ignore it
          if @socket? then @socket.emit 'new tweet', tweet


  #
  # ### Utilities
  #
  #   - Pass a tweet to Buffer
  #   - Identify node.js (arduino) vs. browser clients
  #   - Keep tabs on when a type of client is connected or disconnected
  #   - Find out if a type of client is connected or disconnected
  #
  save: (tweet) ->
    @logger.save "@#{tweet.user.screen_name}: #{tweet.text}"
    Buffer.process tweet, @jobs


  identify: (socket) ->
    if socket.handshake.headers['user-agent'] is 'node.js'
      identity = 'arduino'
    else identity = 'browser'
    return identity


  rollCall: (status, socket) ->
    identity = @identify socket
    if @roll[identity] is true then @roll[identity] = false
    else @roll[identity] = true
    if @roll[identity] is true then @logger.connect identity
    else @logger.disconnect identity


  isPresent: (identity) ->
    if @roll[identity] is true then return true
    else return false
