express = require 'express'
stylus = require 'stylus'
connect = require 'connect'
stitch = require 'stitch'
app = express.createServer()
url = require 'url'
kue = require 'kue'
redis = require 'kue/node_modules/redis'
port = process.env.PORT || 1110


#TODO: Finish conversion of underscore.js templating to Plates.js

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



# ###Asset Middleware
#
#   - Use stitch to package and serve clientside CoffeeScript modules
#   - Use stylus to precompile CSS
#
package = stitch.createPackage paths:["#{__dirname}/src/client/javascripts"], dependencies:["#{__dirname}/public/javascripts/jquery.js","#{__dirname}/public/javascripts/socket.io.js","#{__dirname}/public/javascripts/plates.js"]

cssOptions =
  src:"#{__dirname}/src/client"
  dest:"#{__dirname}/public"
  compile:compile

compile = (str, path) ->
  stylus(str)
    .import "#{__dirname}/src/client/stylesheets"
    .set 'filename', path
    .set 'compress', true


#
# ###Web Server
#
#   - Use stylus and stitch middleware with an express webserver
#   - Serve index.html from the public dir
#   - Start the app and queue servers
#
viewOptions =
  locals:
    title:'Holicray by Designkitchen'
  layout:'layout'

app.configure () ->
  app.use app.router
  app.use stylus.middleware cssOptions
  app.use 'views', "#{__dirname}/src/client/views"
  app.use 'view engine', 'jade'
  app.get '/application.js', package.createServer()

app.configure 'development', ->
  app.use express.static "#{__dirname}/public"
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  oneYear = 31557600000;
  app.use express.static "#{__dirname}/public", maxAge: oneYear
  app.use express.errorHandler()


app.get '/', (req, res) ->
  res.render "#{__dirname}/src/client/views/index.jade", viewOptions

app.use kue.app
app.listen port


Logger = require './src/server/logger'
logger = new Logger()

Stream = require './src/server/stream'
Stream.init app, jobs, logger
