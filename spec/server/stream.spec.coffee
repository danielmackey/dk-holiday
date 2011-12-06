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

