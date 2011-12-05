request = require 'request'
Logger = require './logger'
Stream = require './stream'
Util = require '../shared/utility'
logger = new Logger()


module.exports = class Holicray
  constructor: (@app, @jobs, @conf) ->
    env = process.env.NODE_ENV || 'development'
    @stats = @conf.get "stats_url:#{env}"
    @init()

  init: ->
    #
    # ### Request the app stats to restore how cray it's been
    #
    request uri:@stats, (error, response, body) =>
      if !error and response.statusCode is 200
        split = body.toString().split(',')
        number = split[1].split(':')[1]
        tally = Util.factorForty number
      else
        tally = 0

      Stream.init @app, @jobs, logger, tally
