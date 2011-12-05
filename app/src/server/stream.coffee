twitter = require 'ntwitter'
Worker = require "#{__dirname}/worker"


#FIXME: write spec for Stream

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
    Worker.init @jobs, @logger, @tally

  #
  # ### Websocket
  #
  #   - Open a websocket connection and open a Twitter stream
  #   - Start Worker
  #   - Take roll call using handshakeData on client connection and disconnection
  #   - Broadcast the 'right now' event from arduino
  #
  openSocket: ->
    io = require('socket.io').listen @app
    io.set 'log level', 1
    io.set 'authorization', (handshakeData, callback) -> callback null, true
    ws = io.of('/arduino').on 'connection', (socket) => @connect socket

  connect: (socket) ->
    unless @api? then @openTwitter socket
    Worker.rollCall 'present', socket
    Worker.start socket
    socket.on 'disconnect', -> Worker.rollCall 'absent', socket
    socket.on 'right now', -> socket.broadcast.emit 'refresh stats'



  #
  # ### Twitter Stream
  #
  #   - Open a twitter stream following @users
  #   - Ignore the first stream payload - its an array of friends
  #   - Capture new tweets and assign to Worker
  #
  openTwitter: (socket) ->
    @api = new twitter @keys
    @api.stream 'user', track:@users, (stream) =>
      @logger.twitter '', 'following':@users
      stream.on 'data', (tweet) =>
        unless tweet.friends? then @saveTweet tweet, socket


  saveTweet: (tweet, socket) ->
    @logger.save "@#{tweet.user.screen_name}: #{tweet.text}"
    socket.broadcast.emit 'refresh stats'
    Worker.assign tweet
