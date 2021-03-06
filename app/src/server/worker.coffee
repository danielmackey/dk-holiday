module.exports = Worker =
  processing:false
  delay:10000 # Delay between jobs being processed
  eventTally:0 # Keep a running tally of events to compare against tippingPoin
  tippingPoint:40 # Point at which it gets cray
  tubemanTrigger:'tube' # FIXME: Change up secret hashtag to trigger the tubeman each day
  events:[
    'the table lights dance.'
    'the sirens go to town.'
    'the wall lights turn on.'
    'the stars light up.'
    'it snow up in here.'
  ]



  # #### Setup Worker with jobs, a logger, and a restored state starting tally
  init: (@jobs, @logger, tally) -> @eventTally = tally



  #
  # #### Conditionally start Worker
  #
  #   - Start processing jobs if arduino is connected
  #   - Start listening on websocket events unless already listening
  #
  start: (socket) -> unless @processing is true then @processJobs socket



  # Assign an incoming tweet to an arduino event
  assign: (tweet) ->
    tubeman = @tubemanTrigger
    hashtags = @getHashtags tweet
    @tally()
    if @eventTally is @tippingPoint
      event = 'it Holicray!'
    else if hashtags.indexOf(tubeman) is -1
      event = @random()
    else
      event = 'the wacky tube man dance.'
    @assembleJob event, tweet


  getHashtags: (tweet) ->
    hashtags = []
    tweet.entities.hashtags.forEach (tag, i) -> hashtags.push tag.text.toLowerCase()
    return hashtags


  # Pick a random event
  random: ->
    event = @events[Math.floor(Math.random() * @events.length)]
    return event



  # Increment eventTally to reach tippingPoint
  tally: ->
    @eventTally++
    return @eventTally



  # Assemble jobData from the incoming tweet data
  assembleJob: (type, data) ->
    jobData =
      title:data.text
      handle:data.user.screen_name
      avatar:data.user.profile_image_url
      event:type
    @createJob type, jobData



  # Create a new job and log job promotion and job completion
  createJob: (type, jobData) ->
    job = @jobs.create(type, jobData).attempts(3).delay(@delay).save()
    job.on 'promotion', -> console.log "10 second pause complete"
    job.on 'complete', -> console.log "Job complete"



  # Process jobs and emit assignment to arduino
  processJobs: (socket) ->
    @processing = true
    @logger.info 'Processing jobs...'

    process = (job, done) =>
      @logger.arduino "##{job.data.event} by @#{job.data.handle}"
      socket.emit 'action assignment', job
      done()

    @jobs.promote()
    @jobs.process 'the table lights dance.', (job, done) -> process job, done
    @jobs.process 'the sirens go to town.', (job, done) -> process job, done
    @jobs.process 'the wall lights turn on.', (job, done) -> process job, done
    @jobs.process 'the stars light up.', (job, done) -> process job, done
    @jobs.process 'it snow up in here.', (job, done) -> process job, done
    @jobs.process 'it Holicray!', (job, done) -> process job, done
    @jobs.process 'the wacky tube man dance.', (job, done) -> process job, done
