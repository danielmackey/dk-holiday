Stream = require '../../app/src/server/stream'
Worker = require '../../app/src/server/worker'

describe 'Stream', ->
  it 'follows @designkitchen', ->
    expect(Stream.users.indexOf('designkitchen')).toNotBe -1

  it 'has access keys for Twitter', ->
    expect(Stream.keys).toBeDefined()

  it 'opens a websocket', ->
    spyOn Stream, 'setupSocket'
    Stream.init {}, {}, {}, 1
    expect(Stream.setupSocket).toHaveBeenCalled()

  it 'initializes Worker with jobs, a logger, and a starting tally', ->
    spyOn Stream, 'setupWorker'
    Stream.init {}, {}, {}, 1
    expect(Stream.setupWorker).toHaveBeenCalled()

  it 'opens a twitter stream on websocket connection', ->
    socket = {}
    spyOn Stream, 'createTwitter'
    Stream.goOnline socket
    expect(Stream.createTwitter).toHaveBeenCalled()

