twitter = require 'ntwitter'
Worker = require "#{__dirname}/worker"


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

  init: (@app, @jobs, @logger, @tally) ->
    @openSocket()
    @openTwitter()
    Worker.init @jobs, @logger, @tally

  #
  # ### Websocket
  #
  #   - Open a connection and start Worker
  #   - Take roll call using handshakeData on client connection and disconnection
  #
  openSocket: ->
    io = require('socket.io').listen @app
    io.set 'log level', 1
    io.set 'authorization', (handshakeData, callback) ->
      callback null, true

    ws = io.of('/arduino').on 'connection', (socket) =>
      Worker.rollCall 'present', socket
      socket.on 'disconnect', -> Worker.rollCall 'absent', socket
      socket.on 'right now', -> socket.broadcast.emit 'refresh stats'
      Worker.start socket


  #
  # ### Twitter Stream
  #
  #   - Open a twitter stream following @users
  #   - Ignore the first stream payload - its an array of friends
  #   - Capture new tweets and assign to Worker
  #
  openTwitter: ->
    api = new twitter @keys
    api.stream 'user', track:@users, (stream) =>
      @logger.twitter '', 'following':@users

      stream.on 'data', (tweet) =>
        unless tweet.friends?
          @logger.save "@#{tweet.user.screen_name}: #{tweet.text}"
          Worker.assign tweet
