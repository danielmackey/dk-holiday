express = require 'express'
stylus = require 'stylus'
connect = require 'connect'
stitch = require 'stitch'
app = express.createServer()
url = require 'url'
kue = require 'kue'
redis = require 'kue/node_modules/redis'
port = process.env.PORT || 1110


#
# ###Job Queue
#
#   - Use redisToGo on Heroku
#   - Enable CORS with the job queue db for clientside stats
#
kue.redis.createClient = () ->
  console.log "process.env.REDISTOGO_URL: " + process.env.REDISTOGO_URL
  process.env.REDISTOGO_URL = process.env.REDISTOGO_URL || "redis://localhost:6379"
  redisUrl = url.parse(process.env.REDISTOGO_URL)
  client = redis.createClient(redisUrl.port, redisUrl.hostname)
  if redisUrl.auth then client.auth(redisUrl.auth.split(":")[1])
  return client

jobs = kue.createQueue()
kue.app.enable "jsonp callback"
kue.app.set 'title', 'DK Holiday'



#
# ###Asset Middleware
#
#   - Use stitch to package and serve clientside CoffeeScript modules
#   - Use stylus to precompile CSS
#
package = stitch.createPackage paths:[__dirname + '/src/client/javascripts'], dependencies:[]

cssOptions =
  src:"#{__dirname}/app/src/client"
  dest:"#{__dirname}/app/public"
  compile:compile

compile = (str, path) ->
  stylus(str)
    .import "#{__dirname}/app/src/client/stylesheets"
    .set 'filename', path
    .set 'compress', true



#
# ###Web Server
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
    res.sendfile "#{__dirname}/app/public/index.html"

app.use kue.app
app.listen port



#
# ##App Workflow
#
#   - Open and listen to a Twitter stream
#   - Capture tweets with relevant hashtags
#   - Create a job for each relevant hashtag and add to queue
#   - Process each job and call buffer
#   - Buffer triggers arduino each time the tipping point is reached
#
Logger = require './src/server/logger'
logger = new Logger()

TwitterStream = require './src/server/twitter'
new TwitterStream jobs, logger

Worker = require './src/server/worker'
new Worker app, jobs, logger
