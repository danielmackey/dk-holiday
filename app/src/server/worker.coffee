module.exports = Worker =
  # ### Setup Worker with jobs, a logger, and a restored state starting tally
  init: (@jobs, @logger, tally) ->
    @eventTally = tally



  #
  # #### Conditionally start Worker
  #
  #   - Start processing jobs if arduino is connected
  #   - Start listening on websocket events unless already listening
  #
  start: (socket) ->
    unless @processing is true then @processJobs socket
    unless @listening is true then @listen socket



  # TODO: Spec out the listening/processing state
  listening:false
  processing:false



  # Listen for websocket events
  listen: (socket) ->
    socket.on 'disconnect', => @rollCall 'absent', socket
    socket.on 'right now', -> socket.emit 'refresh stats'
    @listening = true



  # Delay between jobs being processed
  delay:10000



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
    @processing = true

    process = (job, done) =>
      @logger.arduino "##{job.data.event} by @#{job.data.handle}"
      socket.emit 'action assignment', job
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
