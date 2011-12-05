module.exports = Worker =
  # ### Setup Worker with jobs, a logger, and a restored state starting tally
  init: (@jobs, @logger, @tally) ->
    @eventTally = @tally


  # Log connections and disconnections
  rollCall: (status, socket) ->
    identity = @identify socket
    if @present[identity] is true then @present[identity] = false
    else @present[identity] = true
    if @present[identity] is true then @logger.connect identity
    else @logger.disconnect identity


  # Keep tabs on which type of clients are connected
  present:
    browser:false
    arduino:false


  # Identify a socket as browser or arduino client
  identify: (socket) ->
    if socket.handshake.headers['user-agent'] is 'node.js'
      identity = 'arduino'
    else identity = 'browser'
    return identity


  # Check to see if a given client identity is connected
  isPresent: (identity) ->
    if @present[identity] is true then return true
    else return false


  # Start processing jobs if arduino is connected
  start: (socket) ->
    if @isPresent 'arduino' then @processJobs socket



  # Delay between jobs being processed
  delay:10000 * 2



  # Keep a running tally of events to compare against tippingPoint
  eventTally:0



  # Point at which it gets cray
  tippingPoint:40



  # The list of possible events that lead up to holicray
  events:[ #TODO: Finalize events and sync up with job processes and spec
    'it snow'
    'the lights on the tree blink'
    'the stars light up'
    'the discoball spin'
    'the wacky man dance'
    'the foo bar baz'
  ]



  # Assign an incoming tweet to an arduino event
  assign: (tweet) ->
    @tally()
    if @eventTally is @tippingPoint then event = 'holicray'
    else event = @random()
    @assembleJob event, tweet



  # Pick a random event
  random: ->
    randomize = -> return (Math.round(Math.random())-0.5)
    randomEvent = @events.sort @randomize
    event = randomEvent.pop()
    return event



  # Increment eventTally to reach tippingPoint
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
    job.on 'complete', -> console.log "Job complete"



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
