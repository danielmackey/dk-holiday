express = require 'express'
stylus = require 'stylus'
connect = require 'connect'
stitch = require 'stitch'
url = require 'url'
kue = require 'kue'
redis = require 'kue/node_modules/redis'
fs = require 'fs'
path = require 'path'
nconf = require 'nconf'
app = express.createServer()
State = require './src/server/state'


#TODO: Convert Zepto to jQuery in Parts
#TODO: Convert jasmine specs to mocha
#TODO: Set up Log.ly


#
# ### App Configuration
#
#   - Read values from config.json
#   - Inherit the port from the foreman proc or fall back to app:port
#
configOptions =
  env:true
  argv:true
  store:
    type:'file'
    file:path.join __dirname, '../../../config.json'

conf = new nconf.Provider configOptions
port = process.env.PORT || conf.get 'app:port'



#
# ### Websocket Configuration
#
io = require('socket.io').listen app
io.set 'log level', 1
io.enable 'browser client minification'
io.set 'authorization', (handshakeData, callback) -> callback null, true



#
# ### Job Queue
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
kue.app.set 'title', conf.get 'app:name'



# ### Asset Middleware
#
#   - Use stitch to package and serve clientside CoffeeScript modules and dependencies
#   - Use stylus to precompile CSS
#
javascripts =
  paths:[
    "#{__dirname}/src/client/javascripts"
    "#{__dirname}/src/shared"
  ]
  dependencies:[
    "#{__dirname}/public/javascripts/zepto.min.js"
    "#{__dirname}/public/javascripts/plates.js"
    "#{__dirname}/public/javascripts/underscore.min.js"
  ]

stylesheets =
  src:"#{__dirname}/src/client"
  dest:"#{__dirname}/public"
  compile:compile

compile = (str, path) ->
  stylus(str)
    .import "#{__dirname}/src/client/stylesheets"
    .set 'filename', path
    .set 'compress', true

package = stitch.createPackage javascripts



#
# ### Web Server
#
#   - Use stylus and stitch middleware with an express webserver
#   - Serve index.html from the public dir
#   - Start the app and queue servers
#
viewOptions =
  locals:
    title:conf.get 'app:name'
  layout:'layout'

app.configure () ->
  app.use app.router
  app.use stylus.middleware stylesheets
  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/src/client/views"

app.configure 'development', ->
  app.use express.static "#{__dirname}/public"
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  app.use express.static "#{__dirname}/public", maxAge:conf.get 'app:cache'
  app.use express.errorHandler()

app.get '/application.js', package.createServer()
app.get '/', (req, res) ->
  res.render "index", viewOptions

app.use kue.app
app.listen port



# #### Restore the state of the app
State.restore jobs, io, conf
