Buffer = require '../../app/src/server/buffer'
Worker = require '../../app/src/server/worker'

describe 'Buffer', ->
  it 'contains 10 events', ->
    eventCount = Buffer.events.length
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
      expect(Buffer.events).toContain event


  it 'processes an incoming tweet', ->
    jobs = {}
    tweet = {}
    spyOn Buffer, 'tally'
    spyOn Buffer, 'random'
    spyOn Buffer, 'queue'
    Buffer.process tweet, jobs
    expect(Buffer.tally).toHaveBeenCalled()
    expect(Buffer.random).toHaveBeenCalled()
    expect(Buffer.queue).toHaveBeenCalled()


  it 'randomly assigns an event', ->
    event = Buffer.random()
    expect(Buffer.events.indexOf(event)).toBeTruthy()


  it 'increments the event tally', ->
    preTally = Buffer.eventTally
    Buffer.tally()
    postTally = Buffer.eventTally
    expect(postTally = preTally + 1).toBeTruthy()


  it 'creates a new job with Worker', ->
    type = 'holicray'
    tweet = {}
    spyOn Worker, 'assembleJob'
    Buffer.queue type, tweet
    expect(Worker.assembleJob).toHaveBeenCalled()
