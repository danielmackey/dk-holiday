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
Holicray = require './src/server/holicray'



#TODO: FIX THIS SHIT
#
#   - When arduino is disconnected, jobs still get made and stay in delayed queue
#   - Once arduino connects, the job is promoted but the action assignment doesn't get resent (undefined socket?)
#   - Emit 'refresh stats' when a job is created
#   - Emit 'refresh stats' when a job is completed
#

#TODO: Replace jQuery and other dependencies with ender lib



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
#   - Use stitch to package and serve clientside CoffeeScript modules
#   - Use stylus to precompile CSS
#"#{__dirname}/public/javascripts/plates.js"
package = stitch.createPackage paths:["#{__dirname}/src/client/javascripts","#{__dirname}/src/shared"], dependencies:["#{__dirname}/public/javascripts/jquery.js","#{__dirname}/public/javascripts/plates.js","#{__dirname}/public/javascripts/socket.io.js"]

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
  app.use stylus.middleware cssOptions
  app.use 'view engine', 'jade'
  app.get '/application.js', package.createServer()

app.configure 'development', ->
  app.use express.static "#{__dirname}/public"
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  app.use express.static "#{__dirname}/public", maxAge:conf.get 'app:cache'
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render "#{__dirname}/src/client/views/index.jade", viewOptions

app.use kue.app
app.listen port


# ### That shit cray
new Holicray app, jobs, conf
