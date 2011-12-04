module.exports = Worker =
  #
  # ## Utilities
  #
  init: (@jobs, @logger, @count) ->
    if @count? then @eventTally = @count

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
  delay:10000
  eventTally:0
  tippingPoint:40

  events:[ #TODO: Finalize events and sync up with job processes and spec
    'it snow'
    'the lights on the tree blink'
    'the stars light up'
    'the discoball spin'
    'the wacky man dance'
    'the foo bar baz'
  ]

  assign: (tweet) ->
    @tally()
    if @eventTally is @tippingPoint then event = 'holicray'
    else event = @random()
    @assembleJob event, tweet

  random: ->
    randomize = -> return (Math.round(Math.random())-0.5)
    randomEvent = @events.sort @randomize
    event = randomEvent.pop()
    return event

  tally: ->
    @eventTally++
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
    job = @jobs.create(type, jobData).attempts(3).delay(@delay).save()
    job.on 'promotion', -> console.log "10 second pause complete"


  processJobs: (socket) ->
    process = (job, done) =>
      @logger.arduino "##{job.data.event} by @#{job.data.handle}"
      socket.broadcast.emit 'action assignment', job
      done()

    @jobs.promote()

    @jobs.process 'it snow', (job, done) ->
      process job, done

    @jobs.process 'the lights on the tree blink', (job, done) ->
      process job, done

    @jobs.process 'the stars light up', (job, done) ->
      process job, done

    @jobs.process 'the discoball spin', (job, done) ->
      process job, done

    @jobs.process 'the wacky man dance', (job, done) ->
      process job, done

    @jobs.process 'the foo bar baz', (job, done) ->
      process job, done

    @jobs.process 'holicray', (job, done) ->
      process job, done
