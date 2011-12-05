Stream = require '../../app/src/server/stream'
Worker = require '../../app/src/server/worker'

describe 'Stream', ->
  it 'follows @designkitchen', ->
    expect(Stream.users.indexOf('designkitchen')).toNotBe -1

  it 'has access keys for Twitter', ->
    expect(Stream.keys).toBeDefined()

  it 'opens a websocket', ->
    spyOn Stream, 'openSocket'
    Stream.init {}, {}, {}, 1
    expect(Stream.openSocket).toHaveBeenCalled()

  it 'initializes Worker with jobs, a logger, and a starting tally', ->
    spyOn Worker, 'init'
    Stream.init {}, {}, {}, 1
    expect(Worker.init).toHaveBeenCalled()

  it 'opens a twitter stream on websocket connection', ->
    socket = {}
    spyOn Stream, 'openTwitter'
    Stream.connect socket
    expect(Stream.openTwitter).toHaveBeenCalled()

