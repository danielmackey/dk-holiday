Stream = require '../../app/src/server/stream'
Buffer = require '../../app/src/server/buffer'

describe 'Socket stream', ->
  it 'checks if the arduino client is connected', ->
    identity = 'arduino'
    Stream.roll.arduino = true
    present = Stream.isPresent identity
    expect(present).toBeTruthy()

  it 'identifies the arduino client', ->
    socket =
      handshake:
        headers:
          'user-agent':'node.js'
    identity = Stream.identify socket
    expect(identity).toMatch 'arduino'

  it 'identifies a browser client', ->
    socket =
      handshake:
        headers:
          'user-agent':'browser'
    identity = Stream.identify socket
    expect(identity).toMatch 'browser'


describe 'Twitter stream', ->
  it 'saves incoming tweets', ->
    tweet =
      text:'Lorem ipsum dolor sit amet'
      user:
        screen_name:'ConanObrien'
        profile_image_url:'http://placehold.it/90x90'

    spyOn Buffer, 'process'
    Stream.save tweet
    expect(Buffer.process).toHaveBeenCalled()
