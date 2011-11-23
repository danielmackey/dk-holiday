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
port = process.env.PORT || 1110
io = require('socket.io').listen app
io.set 'log level', 1



#
# ###Queue config
#
#   - Use redisToGo on Heroku
#   - Enable CORS with the job queue db for clientside stats
#
kue.redis.createClient = () ->
  process.env.REDISTOGO_URL = process.env.REDISTOGO_URL || "redis://localhost:6379"
  redisUrl = url.parse(process.env.REDISTOGO_URL)
  client = redis.createClient(redisUrl.port, redisUrl.hostname)
  if redisUrl.auth then client.auth(redisUrl.auth.split(":")[1])
  return client

jobs = kue.createQueue()
kue.app.enable "jsonp callback"
kue.app.set 'title', 'DK Holiday'



#
# ###Asset config
#
#   - Use stitch to package and serve clientside CoffeeScript modules
#   - Use stylus to precompile CSS
#
package = stitch.createPackage paths:[__dirname + '/src/javascripts'], dependencies:[]

cssOptions =
  src:"#{__dirname}/src"
  dest:"#{__dirname}/public"
  compile:compile

compile = (str, path) ->
  stylus(str)
    .import "#{__dirname}/src/stylesheets"
    .set 'filename', path
    .set 'compress', true



#
# ###Logging config
#
#   - Use winston on the console with custom log levels and coloring
#   - Optionally log to a file transport
#
logLevels =
  levels:
    info:0
    warn:1
    error:2
  colors:
    info:'green'
    warn:'yellow'
    error:'red'

`var logger = new (winston.Logger)({
  transports:[
    new (winston.transports.Console)({
      colorize:true
    })
  ],
  levels:logLevels.levels,
  colors:logLevels.colors
});
winston.addColors(logLevels.colors);`



#
# ###Twitter config
# TODO: Get production keys with @designkitchen account
#
#   - Pluck tweets with hashtags that exist in the tags array
#   - Follow @designkitchen for production and @holiduino during development
#
twitterOptions =
  consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
  consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
  access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
  access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'

tags = [
  'snow'
  'lights'
  'train'
  'discoball'
  'fan'
]

users = [
  'designkitchen'
  'holiduino'
]

twit = new twitter twitterOptions



#
# ###Buffer config
#
#   - Set tipping points in the thresholds object
#   - Each tipping point determines the individual frequency of events
#
buffer = (n) ->
  nth = n
  rnd = Math.floor(Math.random() * nth) + 1
  if rnd is nth then return true
  else return false

thresholds =
  "snow":1
  "lights":1
  "train":3
  "discoball":1
  "fan":1



#
# ##Streaming
#
#   - Grab tweets @designkitchen
#   - Filter for hashtags. Only tweets with hashtags are caught
#   - Filter for relevancy. Only tweets with hashtags in the tags array are saved
#   - Create a job for each relevant hashtag
#
twit.stream 'user', track:users, (stream) ->
  logger.info 'Twitter stream opened', 'following':users
  stream.on 'data', (data) ->
    if data.friends is undefined # The first stream message is an array of friend IDs, ignore it
      hashtags = data.entities.hashtags

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

            jobs.create(hashtag, jobData).attempts(3).save()



#
# ##Messaging
#
#   - 2 websocket channels: 1 for browser clients and 1 for arduino
#   - Announce connections and disconnections
#   - Announce completed actions
#   - Requires both channels to be connected for jobs to process
#
arduino = io.of('/arduino').on 'connection', (arduino_socket) ->
  logger.info 'Arduino connected', 'ready':true

  client = io.of('/client').on 'connection', (client_socket) ->
    logger.info 'Client connected', 'audience':true
    client_socket.emit 'arduino connected'

    arduino_socket.on 'action complete', (job) ->
      logger.info 'Arduino action complete', 'action':job.data.hashtag
      client_socket.emit 'new event', job

    arduino_socket.on 'disconnect', () ->
      logger.info 'Arduino disconnected', 'ready':false
      client_socket.emit 'arduino disconnected'


    #
    # ##Processing
    #
    #   - Process each type of job and add a tally mark
    #   - Jobs and arduino calls are not 1:1. buffer() uses the values defined in the thresholds object to create tipping points for each action
    #   - Call arduino with an action assignment when the tipping point is reached
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
# ##Consuming
#
#   - Use stylus and stitch middleware with an express webserver
#   - Serve index.html from the public dir
#   - Start the app and queue servers
#
app.configure () ->
  app.use app.router
  app.use stylus.middleware cssOptions
  app.use express.static "#{__dirname}/public"
  app.get '/application.js', package.createServer()
  app.get '/', (req, res) ->
    res.sendfile "#{__dirname}/public/index.html"

app.listen port
app.use kue.app
