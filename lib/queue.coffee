url = require 'url'
redis = require 'kue/node_modules/redis'

module.exports = class Queue
  constructor: (@app) ->
    #
    # ###Queue config
    #
    #   - Use redisToGo on Heroku
    #   - Enable CORS with the job queue db for clientside stats
    #
    @kue = require 'kue'
    @kue.redis.createClient = () ->
      process.env.REDISTOGO_URL = process.env.REDISTOGO_URL || "redis://localhost:6379"
      redisUrl = url.parse(process.env.REDISTOGO_URL)
      client = redis.createClient(redisUrl.port, redisUrl.hostname)
      if redisUrl.auth then client.auth(redisUrl.auth.split(":")[1])
      return client

    @jobs = @kue.createQueue()
    console.log @jobs

  jobs: () ->
    return @jobs

  app: () ->
    @kue.app.enable "jsonp callback"
    @kue.app.set 'title', 'DK Holiday'
    return @kue.app
