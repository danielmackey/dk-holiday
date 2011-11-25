stitch = require 'stitch'
express = require 'express'
stylus = require 'stylus'
connect = require 'connect'
app = express.createServer()
port = process.env.PORT || 1110

#
# ###Asset middleware config
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

module.exports = class WebServer
  constructor: (@options) ->
    @init()

  init: () ->
    #
    # ##Client Web Server
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
    if @options.plugin? then app.use @options.plugin
    return app
