Worker = require '../../app/src/server/worker'

describe 'Worker', ->
  it 'attaches the queue and logger', ->
    jobs = {}
    logger = {}
    Worker.init jobs, logger
    expect(Worker.jobs).toBeDefined()
    expect(Worker.logger).toBeDefined()

  it 'assembles and creates a new job', ->
    jobs = {}
    type = 'holicray'
    data =
      text:'Lorem ipsum dolor sit amet'
      user:
        screen_name:'ConanObrien'
        profile_image_url:'http://placehold.it/90x90'

    spyOn Worker, 'createJob'
    Worker.assembleJob type, data, jobs
    expect(Worker.createJob).toHaveBeenCalled()


  it 'processes jobs if arduino is connected', ->


  it 'saves incoming tweets', ->
    tweet =
      text:'Lorem ipsum dolor sit amet'
      user:
        screen_name:'ConanObrien'
        profile_image_url:'http://placehold.it/90x90'

    spyOn Worker, 'assembleJob'
    #Worker.assign tweet
    expect(Worker.assembleJob).toHaveBeenCalled()


  it 'checks if the arduino client is connected', ->
    identity = 'arduino'
    Worker.roll.arduino = true
    present = Worker.isPresent identity
    expect(present).toBeTruthy()

  it 'identifies the arduino client', ->
    socket =
      handshake:
        headers:
          'user-agent':'node.js'
    identity = Worker.identify socket
    expect(identity).toMatch 'arduino'

  it 'identifies a browser client', ->
    socket =
      handshake:
        headers:
          'user-agent':'browser'
    identity = Worker.identify socket
    expect(identity).toMatch 'browser'


  it 'contains 10 events', ->
    eventCount = Worker.events.length
    expect(eventCount).toEqual 10

  it 'contains the correct events', ->
    #TODO: Finalize events and sync up with spec
    events = [
      'snow'
      'lights'
      'train'
      'discoball'
      'fan'
      'foo'
      'bar'
      'baz'
      'lorem'
      'ipsum'
    ]

    events.forEach (event, i) ->
      expect(Worker.events).toContain event


  it 'processes an incoming tweet', ->
    tweet = {}
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
    preTally = Worker.eventTally
    Worker.tally()
    postTally = Worker.eventTally
    expect(postTally = preTally + 1).toBeTruthy()
