TwitterStream = require '../../app/src/server/twitter'

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
    ts = new TwitterStream jobs logger
    spyOn TwitterStream, 'noHashtags'
    TwitterStream.filter Tweet.noHashtags
    expect(TwitterStream.noHashtags).toHaveBeenCalled()

  #it 'drops tweets with irrelevant hashtags', ->

  #it 'saves tweets with relevant hashtags', ->

