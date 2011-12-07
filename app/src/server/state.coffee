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
  restore: (@jobs, @io, @conf) ->
    env = process.env.NODE_ENV || 'development'
    url = @conf.get "stats_url:#{env}" || 'http://holiday.designkitchen.com'
    @inflate url

#FIXME: Commented out request for testing purposes on Heroku
  inflate: (url) ->
    #request uri:url, (error, response, body) =>
      #if !error and response.statusCode is 200
        #split = body.toString().split(',')
        #number = split[1].split(':')[1]
        #tally = Util.factorForty number
      #else
        #tally = 0

      tally = 0
      Stream.init @jobs, @io, logger, tally
