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



  init: (@jobs, @io, @logger, @tally) ->
    @setupSocket()
    @setupWorker()



  setupWorker: ->
    Worker.init @jobs, @logger, @tally



  setupSocket: ->
    ws = @io.of('/arduino').on 'connection', (socket) => @goOnline socket



  # #### Websocket Connection
  #
  #   - Called on websocket connection
  #   - Open Twitter stream
  #   - Take roll call using handshakeData on client connection and disconnection
  #   - Start Worker
  #   - Broadcast the 'right now' event from arduino
  #
  goOnline: (socket) ->
    unless @twitter? then @setupTwitter socket
    Worker.rollCall 'present', socket
    Worker.start socket
    socket.on 'disconnect', -> Worker.rollCall 'absent', socket
    socket.on 'right now', -> socket.broadcast.emit 'refresh stats'



  #
  # #### Twitter Stream
  #
  #   - Open a twitter stream following @users
  #   - Ignore the first stream payload - its an array of friends
  #   - Log the stream users
  #   - On new data, save the tweet unless it's the friends array
  #
  setupTwitter: (socket) ->
    @twitter = new twitter @keys
    @twitter.stream 'user', track:@users, (stream) =>
      @logger.twitter '', 'following':@users
      stream.on 'data', (tweet) =>
        unless tweet.friends? then @save tweet, socket



  #
  # #### Save
  #
  #   - Log the saved tweet
  #   - Broadcast 'refresh stats' event
  #   - Capture new tweets and assign to Worker
  #
  save: (tweet, socket) ->
    @logger.save "@#{tweet.user.screen_name}: #{tweet.text}"
    socket.broadcast.emit 'refresh stats'
    Worker.assign tweet
