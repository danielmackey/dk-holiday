express = require 'express'
stylus = require 'stylus'
colors = require 'colors'
connect = require 'connect'
stitch = require 'stitch'
twitter = require 'ntwitter'
url = require 'url'
app = express.createServer()
kue = require 'kue'
winston = require 'winston'
redis = require 'kue/node_modules/redis'

# Configure Redis
kue.redis.createClient = () ->
  process.env.REDISTOGO_URL = process.env.REDISTOGO_URL || "redis://localhost:6379"
  redisUrl = url.parse(process.env.REDISTOGO_URL)
  client = redis.createClient(redisUrl.port, redisUrl.hostname)
  if redisUrl.auth then client.auth(redisUrl.auth.split(":")[1])
  return client

jobs = kue.createQueue()
port = process.env.PORT || 1110
io = require('socket.io').listen app
io.set 'log level', 1
package = stitch.createPackage paths:[__dirname + '/src/javascripts'], dependencies:[]

# Configure stylus to compile and serve all .styl files
cssOptions =
  src:"#{__dirname}/src"
  dest:"#{__dirname}/public"
  compile:compile


# Define a custom compiler for stylus
compile = (str, path) ->
  stylus(str)
    .import "#{__dirname}/src/stylesheets"
    .set 'filename', path
    .set 'compress', true


#
# Configure custom logging
#
logLevels =
  levels:
    info: 0
    warn: 1
    error:2
  colors:
    info: 'green'
    warn: 'yellow'
    error: 'red'


`var logger = new (winston.Logger)({
  transports:[
    new (winston.transports.Console)()
  ],
  levels:logLevels.levels
});

winston.addColors(logLevels.colors);`

#
# Configure twitter
#
# TODO: Get production keys with @designkitchen account
#
twitterOptions =
  consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
  consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
  access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
  access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'


buffer = (n) ->
  nth = n
  rnd = Math.floor(Math.random() * nth) + 1
  if rnd is nth then return true
  else return false


tags = [
  'snow'
  'lights'
  'train'
  'discoball'
  'fan'
]

# Set buffer thresholds for each trigger for desired frequency
thresholds =
  "snow":1
  "lights":1
  "train":3
  "discoball":1
  "fan":1

# Create a new twitter stream
twit = new twitter twitterOptions

users = [
  'designkitchen'
  'holiduino'
]


#
# ## Twitter stream
#
#   - Create jobs for each #tag @designkitchen
#
twit.stream 'user', track:users, (stream) ->
  logger.info 'Twitter stream opened', 'following':users
  stream.on 'data', (data) ->
    if data.friends is undefined # The first stream message is an array of friend IDs, ignore it
      hashtags = data.entities.hashtags

      # Only capture tweets with a hashtag
      if hashtags.length is 0
        logger.warn 'Tweet discarded', 'hashtags':hashtags.length
      else
        logger.info 'Tweet received', 'hashtags':hashtags.length
        hashtags.forEach (hashtag, i) ->
          hashtag = hashtag.text
          if tags.indexOf(hashtag) is -1
            logger.warn 'Tweet discarded', 'relevant':false
          else
            logger.info 'Tweet saved', 'hashtag':hashtag, 'jobsCreated':1
            jobData =
              title:data.text
              handle:data.user.screen_name
              avatar:data.user.profile_image_url
              hashtag:hashtag

            # Create a new arduino job with 3 attempts for each hashtag trigger
            jobs.create(hashtag, jobData).attempts(3).save()



#
# ##Arduino Socket
#
#   - Listen for connections namspaced to /arduino
#   - On connection, kick off job queue
#
arduino = io.of('/arduino').on 'connection', (arduino_socket) ->
  logger.info 'Arduino connected', 'ready':true

  #
  # ##Client Socket
  #
  #
  client = io.of('/client').on 'connection', (client_socket) ->
    logger.info 'Client connected', 'audience':true
    #
    # ## Socket communication
    #
    #   - Listen for completed actions
    #   - Update the clients with new events
    #   - Announce when out of commission
    #
    arduino_socket.on 'action complete', (job) ->
      client_socket.emit 'new event', job

    arduino_socket.on 'disconnect', () ->
      client_socket.emit 'arduino disconnected'

    client_socket.emit 'arduino connected'

    #
    # ##Job Processor
    #
    #   - Process all 'arduino action' jobs
    #   - Send message to activate arduino every nth time
    #   - Add a tally mark all other times
    #
    process = (job, done) ->
      buffer_count = thresholds[job.data.hashtag]
      if buffer(buffer_count)
        arduino_socket.emit 'action assignment', job
        logger.info 'Arduino call', 'action':job.data.hashtag, 'by':job.data.handle
      else
        client_socket.emit 'tally mark', job
        logger.info 'Tally for arduino call', 'action':job.data.hashtag, 'by':job.data.handle
      done()

    jobs.process 'snow', (job, done) ->
      process job, done

    jobs.process 'lights', (job, done) ->
      process job, done

    jobs.process 'train', (job, done) ->
      process job, done

    jobs.process 'discoball', (job, done) ->
      process job, done


#
# ##Configure the App server
#
#   - Use stylus and stitch middleware
#   - Serve index.html from the public dir
#
app.configure () ->
  app.use app.router
  app.use stylus.middleware cssOptions
  app.use express.static "#{__dirname}/public"
  app.get '/application.js', package.createServer()
  app.get '/', (req, res) ->
    res.sendfile "#{__dirname}/public/index.html"

# Start the App server
app.listen port

# Start the Queue server
kue.app.enable "jsonp callback"
kue.app.set 'title', 'DK Holiday'
app.use kue.app
