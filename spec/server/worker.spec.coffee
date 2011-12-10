Worker = require '../../app/src/server/worker'


jobs = {}
logger = {}
tweet =
  text:'Lorem ipsum dolor sit amet'
  user:
    screen_name:'ConanObrien'
    profile_image_url:'http://placehold.it/90x90'
  entities:
    hashtags:[]


describe 'Worker', ->
  it 'has a queue', ->
    Worker.init jobs, logger
    expect(Worker.jobs).toBeDefined()

  it 'has a logger', ->
    Worker.init jobs, logger
    expect(Worker.logger).toBeDefined()

  it 'assembles and creates a new job', ->
    type = 'holicray'
    data =
      text:'Lorem ipsum dolor sit amet'
      user:
        screen_name:'ConanObrien'
        profile_image_url:'http://placehold.it/90x90'

    spyOn Worker, 'createJob'
    Worker.assembleJob type, data, jobs
    expect(Worker.createJob).toHaveBeenCalled()

  it 'contains 6 events', ->
    eventCount = Worker.events.length
    expect(eventCount).toEqual 6

  it 'contains the correct events', ->
    events = [
      'it snow'
      'the lights on the tree blink'
      'the stars light up'
      'the discoball spin'
      'the wacky man dance'
      'the foo bar baz'
    ]

    events.forEach (event, i) ->
      expect(Worker.events).toContain event


  it 'processes an incoming tweet', ->
    spyOn Worker, 'tally'
    spyOn Worker, 'random'
    spyOn Worker, 'assembleJob'
    Worker.assign tweet
    expect(Worker.tally).toHaveBeenCalled()
    expect(Worker.random).toHaveBeenCalled()
    expect(Worker.assembleJob).toHaveBeenCalled()


  it 'randomly assigns an event', ->
    event = Worker.random()
    expect(Worker.events.indexOf(event)).toBeTruthy()


  it 'increments the event tally', ->
    Worker.init {}, {}, 10
    preTally = Worker.eventTally
    Worker.tally()
    postTally = Worker.eventTally
    expect(postTally).toEqual(preTally + 1)

  it 'saves incoming tweets', ->
    spyOn Worker, 'assembleJob'
    Worker.assign tweet
    expect(Worker.assembleJob).toHaveBeenCalled()


