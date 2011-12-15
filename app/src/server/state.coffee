request = require 'request'
Logger = require './logger'
Stream = require './stream'
Util = require '../shared/utility'
logger = new Logger()



# ### State
#
#   - Restore the state of the app
#   - Request the app stats to restore how cray it's been. If unavailable, reset tally to 0

module.exports = State =
  restore: (@jobs, @io) ->
    env = process.env.NODE_ENV || 'development'
    url = 'http://holiday.designkitchen.com/stats'
    @inflate url

  inflate: (url) ->
    request uri:url, (error, response, body) =>
      if !error and response.statusCode is 200
        split = body.toString().split(',')
        number = split[1].split(':')[1]
        tally = Util.factorForty number - 4
      else
        tally = 0

      console.log 'restored cray tally count: ', tally
      Stream.init @jobs, @io, logger, tally
