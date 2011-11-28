Buffer = require './buffer'

#
# ###Buffer config
#
#   - Set tipping points in the thresholds object
#   - Each tipping point determines the individual frequency of events
#
thresholds =
  "snow":1
  "lights":1
  "train":3
  "discoball":1
  "fan":1


module.exports = class Worker
  constructor: (@app, @jobs, @logger) ->
    @init()

  init: ->
    @openSocket()

  openSocket: ->
    #
    # ####Websocket config
    #
    #   - Listen on the same port as the webserver app
    #   - Reduce logging levels to low
    #   - Expose socket handshake data for identification
    #
    io = require('socket.io').listen @app
    io.set 'log level', 1
    io.set 'authorization', (handshakeData, callback) ->
      callback null, true

    #
    # ####Websocket connection
    #
    #   - Identify each client on connection
    #   - Set rollCall to true for connecting identity
    #   - Log the connecting identity
    #
    ws = io.of('/arduino').on 'connection', (@socket) =>
      identity = @identify @socket
      @rollCall[identity] = true
      @logger.connect identity

      #
      # ####Websocket disconnection
      #
      #   - Identify each client on disconnection
      #   - Set rollCall to false for disconnecting identity
      #   - Log the disconnecting identity
      #
      @socket.on 'disconnect', =>
        identity = @identify @socket
        @rollCall[identity] = false
        @logger.disconnect identity

      #
      # ####Proceed if arduino is connected
      #
      if @rollCall.arduino
        @processJobs()


  processJobs: ->
    #
    # ##Processing
    #
    #   - Process each type of job and add a tally mark
    #   - Jobs and arduino calls are not 1:1. @buffer() uses the values defined in the thresholds object to create tipping points for each action
    #   - Call arduino with an action assignment when the tipping point is reached
    #
    process = (job, done) =>
      count = thresholds[job.data.hashtag]
      if Buffer count
        @logger.arduino "##{job.data.hashtag} by @#{job.data.handle}"
        @socket.emit 'action assignment', job, (completedJob) =>
          @logger.confirm 'Arduino action', 'action':completedJob.data.hashtag
          @socket.emit 'new event', completedJob
          done()
      else
        @logger.tally "#{job.data.hashtag} by #{job.data.handle}"
        @socket.emit 'tally mark', job, (talliedJob) =>
          @logger.confirm "Tally mark counted", 'action':talliedJob.data.hashtag
          done()

    #
    # ####Define a job process for each hashtag
    #
    @jobs.process 'snow', (job, done) ->
      process job, done

    @jobs.process 'lights', (job, done) ->
      process job, done

    @jobs.process 'train', (job, done) ->
      process job, done

    @jobs.process 'discoball', (job, done) ->
      process job, done


  #
  # ###Identifier Utility
  #
  #   - Crude identifier that only distinguishes between node clients and browser clients
  #   - Accepts a socket connection
  #   - Returns the identity as arduino if the client is node.js
  #   - Returns the identity as client if the client is a browser user agent
  #
  identify: (socket) ->
    if socket.handshake.headers['user-agent'] is 'node.js'
      identity = 'arduino'
    else identity = 'browser'
    return identity

  #
  # ###Keep track of which type of client is connected
  #
  rollCall:
    browser:false
    arduino:false
