twitter = require 'ntwitter'
Worker = require "#{__dirname}/worker"



module.exports = Stream =
  users: [
    'designkitchen'
    'holiduino'
  ]



  keys:
    #Original app
    #consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
    #consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
    #access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
    #access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'
    # New app
    consumer_key:'TAyL1gwREECOg7byrIDjLA'
    consumer_secret:'YiyKxhMDxNxmAYz2XSwwxqiXFwYHlv6D3uGBYvg'
    access_token_key:'21787469-cCDu4PpWNhkoYg96CTJZvr3va4KwwC66eSmnDB3w'
    access_token_secret:'mIk8LJXokBQjfW2Yl3kSiqgoc4JZO5FRKRuf9XMBY'
    #Production app
    #consumer_key:'2vaJc8GKN1V0D8H70eQi9Q'
    #consumer_secret:'FYJ6wUaKMqRgS09yCU8aGyMZpiEwbqznXjqgi09jNs'
    #access_token_key:'19734547-xbfVhOwWed3l09ukwqXlwyR6qImbVhA6GpcAlSsE'
    #access_token_secret:'Z6DrTr9JqNoigl03S33Nace4EP7BaJ5THS1qtBM'

  init: (@jobs, @io, @logger, @tally) ->
    @setupSocket()
    @setupWorker()
    @isOpen()


  setupWorker: -> Worker.init @jobs, @logger, @tally



  setupSocket: ->
    @io.sockets.on 'connection', (socket) =>
      @goOnline socket
      socket.on 'right now', (job) => socket.broadcast.emit 'refresh stats', job



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
    open = '8'
    close = '17'
    #close = '24'
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
      stream.on 'data', (tweet) => @filter tweet
      stream.on 'end', (res) => @logger.twitter 'stream disconnected'
      stream.on 'destroy', (res) =>
        @createTwitter()
        @logger.twitter 'stream closed silently'



  filter: (tweet) ->
    if tweet.friends?
    else
      if tweet.entities.user_mentions? and tweet.entities.user_mentions.length > 0
        tweet.entities.user_mentions.forEach (mention, i) =>
          if mention.screen_name is 'designkitchen'
            @save tweet



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
