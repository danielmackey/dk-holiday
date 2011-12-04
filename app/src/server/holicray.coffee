request = require 'request'
Logger = require './logger'
Stream = require './stream'
logger = new Logger()

module.exports = class Holicray
  constructor: (@app, @jobs) ->
    @init()

  init: ->
    #
    # ### Request the app stats to restore how cray it's been
    #
    #FIXME: make URI dynamic based on NODE_ENV
    request uri:'http://localhost:5000/stats', (error, response, body) =>
      if !error and response.statusCode is 200
        split = body.toString().split(',')
        number = split[1].split(':')[1]
        tally = @factorForty number
      else
        tally = 0

      Stream.init @app, @jobs, logger, tally


  #OPTIMIZE: Modularize factorForty() - the same function is used client-side
  factorForty: (n) ->
    if n < 41 then return n
    else
      timesOver = parseInt n / 40, 10
      extra = timesOver * 40
      return n - extra
