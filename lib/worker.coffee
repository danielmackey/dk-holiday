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

rollCall =
  client:false
  arduino:false


module.exports = Worker =
  init: (app, jobs, logger) ->
    #
    # ####Websocket config
    #
    io = require('socket.io').listen app
    io.set 'log level', 1
    io.set 'authorization', (handshakeData, callback) ->
      callback null, true

    #
    # ####Open a websocket connection and identify each client with logger
    #
    io.sockets.on 'connection', (socket) ->
      identity = Worker.identify socket
      rollCall[identity] = true
      logger.connect identity

      #
      # ####Identify each client disconnect with logger
      #
      socket.on 'disconnect', ->
        identity = Worker.identify socket
        rollCall[identity] = false
        logger.disconnect identity

      #
      # ####Proceed if arduino is connected
      #
      if rollCall.arduino
        #
        # ##Processing
        #
        #   - Process each type of job and add a tally mark
        #   - Jobs and arduino calls are not 1:1. @buffer() uses the values defined in the thresholds object to create tipping points for each action
        #   - Call arduino with an action assignment when the tipping point is reached
        #
        process = (job, done) ->
          buffer_count = thresholds[job.data.hashtag]
          if Worker.buffer buffer_count
            logger.arduino "##{job.data.hashtag} by @#{job.data.handle}"
            socket.emit 'action assignment', job, (completedJob) ->
              logger.info 'Arduino action complete', 'action':completedJob.data.hashtag
              socket.emit 'new event', completedJob
              done()
          else
            logger.tally "#{job.data.hashtag} by #{job.data.handle}"
            socket.emit 'tally mark', job, (hashtag) ->
              logger.info "acknowledgement #{hashtag}"
              done()

        #
        # ####Define a job process for each hashtag
        #
        jobs.process 'snow', (job, done) ->
          process job, done

        jobs.process 'lights', (job, done) ->
          process job, done

        jobs.process 'train', (job, done) ->
          process job, done

        jobs.process 'discoball', (job, done) ->
          process job, done


  identify: (socket) ->
    if socket.handshake.headers['user-agent'] is 'node.js'
      identity = 'arduino'
    else identity = 'client'
    return identity


  buffer: (n) ->
    nth = n
    rnd = Math.floor(Math.random() * nth) + 1
    if rnd is nth then return true
    else return false
