TwitterStream = require '../../app/src/server/twitter'
Jasmine = {}
Jasmine.TwitterStream = TwitterStream

# Stub data
Tweet =
  noHashtags:
    entities:
      hashtags:[]

  irrelevantHashtag:
    entities:
      hashtags:[ text:'foo' ]

  relevantHashtag:
    entities:
      hashtag: [ text:'snow' ]

jobs = {}
logger = {}


describe 'Tweet filter', ->
  it 'drops tweets without hashtags', ->
    spyOn(Jasmine, 'TwitterStream').andCallThrough()
    new Jasmine.TwitterStream jobs logger
    #expect(Jasmine.TwitterStream).toHaveBeenCalled()
    #expect(ts instanceof Jasmine.TwitterStream).toBeTruthy()

  #it 'drops tweets with irrelevant hashtags', ->

  #it 'saves tweets with relevant hashtags', ->

