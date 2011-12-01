module.exports = Worker =
  #
  # ## Utilities
  #
  init: (@jobs, @logger) ->

  rollCall: (status, socket) ->
    identity = @identify socket
    if @roll[identity] is true then @roll[identity] = false
    else @roll[identity] = true
    if @roll[identity] is true then @logger.connect identity
    else @logger.disconnect identity


  # #### Keep tabs on which clients are currently connected
  roll:
    browser:false
    arduino:false


  identify: (socket) ->
    if socket.handshake.headers['user-agent'] is 'node.js'
      identity = 'arduino'
    else identity = 'browser'
    return identity


  isPresent: (identity) ->
    if @roll[identity] is true then return true
    else return false


  start: (socket) ->
    if @isPresent 'arduino' then @processJobs socket




  #
  # ## Event Assignment
  #
  eventTally:0
  tippingPoint:40
  #TODO: Finalize events and sync up with spec
  events:[
    'snow'
    'lights'
    'train'
    'discoball'
    'fan'
    'foo'
  ]

  assign: (tweet, socket) ->
    @tally socket
    if @eventTally is @tippingPoint then event = 'holicray'
    else event = @random()
    @assembleJob event, tweet

  random: ->
    randomize = -> return (Math.round(Math.random())-0.5)
    randomEvent = @events.sort @randomize
    event = randomEvent.pop()
    return event

  tally: (socket) ->
    @eventTally++
    if socket? then socket.emit 'tally mark'
    return @eventTally



  #
  # ## Job processor
  #
  #   - Emit a new job to arduino
  #   - Emit a right now message
  #   - Wait for callback of completed job
  #   - Emit a new event and finish job
  #
  assembleJob: (type, data) ->
    jobData =
      title:data.text
      handle:data.user.screen_name
      avatar:data.user.profile_image_url
      event:type
    @createJob type, jobData


  createJob: (type, jobData) ->
    job = @jobs.create(type, jobData).attempts(3).save()
    job.on 'complete', -> console.log "10 second pause complete"


  processJobs: (socket) ->
    process = (job, done) =>
      @logger.arduino "##{job.data.event} by @#{job.data.handle}"
      socket.emit 'action assignment', job, (completedJob) =>
        setTimeout () =>
          @logger.confirm 'Arduino action', 'event':completedJob.data.event
          socket.emit 'new event', completedJob
          done()
        , 10000


    # #### Define a job process for each event
    @jobs.process 'snow', (job, done) ->
      process job, done

    @jobs.process 'lights', (job, done) ->
      process job, done

    @jobs.process 'train', (job, done) ->
      process job, done

    @jobs.process 'discoball', (job, done) ->
      process job, done

    @jobs.process 'holicray', (job, done) ->
      process job, done
