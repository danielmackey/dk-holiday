express = require 'express'
stylus = require 'stylus'
connect = require 'connect'
stitch = require 'stitch'
twitter = require 'ntwitter'
url = require 'url'
app = express.createServer()
kue = require 'kue'
redis = require 'kue/node_modules/redis'
jobs = kue.createQueue()
port = process.env.PORT || 1110
io = require('socket.io').listen app
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
# Configure twitter
#
# TODO: Get production keys with @designkitchen account
#
twitterOptions =
  consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
  consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
  access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
  access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'


# Create a new twitter stream
twit = new twitter twitterOptions

#
# ##Client Socket
#
#   - On client connection, open a Twitter user stream
#   - Broadcast tweets @user #withHashTags
#   - Create arduino jobs from hashtag triggers
#
client = io.of('/client').on 'connection', (client_socket) ->
  twit.stream 'user', track:['designkitchen','holiduino'], (stream) ->
    stream.on 'data', (data) ->
      if data.friends is undefined # The first stream message is an array of friend IDs, ignore it
        hashtags = data.entities.hashtags

        # Only capture tweets with a hashtag
        unless hashtags.length is 0
          # Assemble job data from tweet data
          hashtags.forEach (hashtag, i) ->
            jobData =
              title:data.text
              handle:data.user.screen_name
              avatar:data.user.profile_image_url
              hashtag:hashtag.text

            # Create a new arduino job with 3 attempts for each hashtag trigger
            jobs.create('arduino action', jobData).attempts(3).save()

  #
  # ##Arduino Socket
  #
  #   - Listen for connections namspaced to /arduino
  #   - On connection, kick off job queue
  #
  arduino = io.of('/arduino').on 'connection', (arduino_socket) ->

    #
    client_socket.emit 'arduino connected'

    #
    # ##Job Processor
    #
    #   - Process all 'arduino action' jobs
    #   - Send message to activate arduino
    #
    jobs.process 'arduino action', (job, done) ->
      arduino_socket.emit 'action assignment', job
      done()

    #
    # ##Arduino Confirmation
    #
    #   - Listen for completed actions
    #   - Update the clients with new events
    #   - Announce when out of commission
    #
    arduino_socket.on 'action complete', (job) ->
      client_socket.emit 'new event', job

    arduino_socket.on 'disconnect', () ->
      client_socket.emit 'arduino disconnected'

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

kue.redis.createClient = () ->
  process.env.REDISTOGO_URL = process.env.REDISTOGO_URL || "redis://localhost:6379"
  redisUrl = url.parse(process.env.REDISTOGO_URL)
  client = redis.createClient(redisUrl.port, redisUrl.hostname)
  if redisUrl.auth then client.auth(redisUrl.auth.split(":")[1])
  return client

# Start the Queue server
kue.app.enable "jsonp callback"
kue.app.set 'title', 'DK Holiday'
kue.app.listen "#{port + 1}"
console.log "App server started on port: #{port}, Queue server started on port: #{port + 1}"
