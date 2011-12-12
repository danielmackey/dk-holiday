express = require 'express'
stylus = require 'stylus'
connect = require 'connect'
stitch = require 'stitch'
kue = require 'kue'
fs = require 'fs'
path = require 'path'
State = require './src/server/state'
app = express.createServer()
port = 5000



#
# ### Websocket Configuration
#
io = require('socket.io').listen app
io.enable 'browser client minification'
io.set 'authorization', (handshakeData, callback) -> callback null, true
io.configure 'production', -> io.set 'log level', 1



#
# ### Job Queue
#
#   - Enable CORS with the job queue db for clientside stats
#
jobs = kue.createQueue()
kue.app.enable "jsonp callback"
kue.app.set 'title', 'Queue: Holi-Cray-Matic&trade; by Designkitchen'



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
    #"#{__dirname}/public/javascripts/zepto.min.js"
    #"#{__dirname}/public/javascripts/underscore.min.js"
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
    title:'Holi-Cray-Matic&trade; by Designkitchen'
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
  app.use express.static "#{__dirname}/public", maxAge:31557600000
  app.use express.errorHandler()

app.get '/application.js', package.createServer()
app.get '/', (req, res) ->
  res.render 'index', viewOptions

app.use kue.app
app.listen port



# #### Restore the state of the app
State.restore jobs, io
