twitter = require 'ntwitter'
Worker = require "#{__dirname}/worker"



module.exports = Stream =
  users: [
    'designkitchen'
    'holiduino'
  ]



  keys:
    consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
    consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
    access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
    access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'



  init: (@jobs, @io, @logger, @tally) ->
    @setupSocket()
    @setupWorker()
    @isOpen()


  setupWorker: ->
    Worker.init @jobs, @logger, @tally



  setupSocket: ->
    @io.sockets.on 'connection', (socket) =>
      @goOnline socket
      socket.on 'right now', (job) => @io.sockets.emit 'refresh stats', job



  # #### Websocket Connection
  #
  #   - Open Twitter stream
  #   - Start Worker
  #
  goOnline: (socket) ->
    if @open is true
      unless @twitter? then @createTwitter()
      Worker.start @io.sockets


  open:false


  isOpen: ->
    open = '9'
    #close = '17'
    close = '20'
    date = new Date()
    now = date.getHours()
    if open < now < close
      @open = true
    else @open = false


  #
  # #### Twitter Stream
  #
  #   - Open a twitter stream following @users
  #   - Ignore the first stream payload - its an array of friends
  #   - Log the stream users
  #   - On new data, save the tweet unless it's the friends array
  #
  createTwitter: ->
    @twitter = new twitter @keys
    @twitter.stream 'user', track:@users, (stream) =>
      @logger.twitter '', 'following':@users
      stream.on 'data', (tweet) =>
        unless tweet.friends? then @save tweet



  #
  # #### Save
  #
  #   - Capture new tweets and assign to Worker
  #   - Log the saved tweet
  #   - Broadcast 'refresh stats' event
  #
  save: (tweet) ->
    Worker.assign tweet
    @logger.save "@#{tweet.user.screen_name}: #{tweet.text}"
    @io.sockets.emit 'refresh stats'
