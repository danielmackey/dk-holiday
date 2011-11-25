#
# ###Buffer config
#
#   - Set tipping points in the thresholds object
#   - Each tipping point determines the individual frequency of events
#
buffer = (n) ->
  nth = n
  rnd = Math.floor(Math.random() * nth) + 1
  if rnd is nth then return true
  else return false

thresholds =
  "snow":1
  "lights":1
  "train":3
  "discoball":1
  "fan":1


#
# ##Messaging
#
#   - 2 websocket channels: 1 for browser clients and 1 for arduino
#   - Announce connections and disconnections
#   - Announce completed actions
#   - Requires both channels to be connected for jobs to process
#
rollCall =
  client:false
  arduino:false

checkIdentity = (socket) ->
  if socket.handshake.headers['user-agent'] is 'node.js'
    endpoint = 'arduino'
  else endpoint = 'client'
  return endpoint

module.exports = Worker =
  init: (app, jobs, logger) ->
    #
    # ###Websocket config
    #
    io = require('socket.io').listen app
    io.set 'log level', 1
    io.set 'authorization', (handshakeData, callback) ->
      callback null, true

    io.sockets.on 'connection', (socket) ->
      endpoint = checkIdentity socket
      rollCall[endpoint] = true
      logger.connect endpoint

      socket.on 'disconnect', ->
        endpoint = checkIdentity socket
        rollCall[endpoint] = false
        logger.disconnect endpoint

      socket.on 'action complete', (job) ->
        logger.info 'Arduino action complete', 'action':job.data.hashtag
        socket.emit 'new event', job

      if rollCall.arduino
        #
        # ##Processing
        #
        #   - Process each type of job and add a tally mark
        #   - Jobs and arduino calls are not 1:1. buffer() uses the values defined in the thresholds object to create tipping points for each action
        #   - Call arduino with an action assignment when the tipping point is reached
        #
        process = (job, done) ->
          buffer_count = thresholds[job.data.hashtag]
          if buffer buffer_count
            socket.emit 'action assignment', job
            logger.arduino "##{job.data.hashtag} by @#{job.data.handle}"
          else
            socket.emit 'tally mark', job
            logger.tally "#{job.data.hashtag} by #{job.data.handle}"
          done()

        jobs.process 'snow', (job, done) ->
          process job, done

        jobs.process 'lights', (job, done) ->
          process job, done

        jobs.process 'train', (job, done) ->
          process job, done

        jobs.process 'discoball', (job, done) ->
          process job, done
