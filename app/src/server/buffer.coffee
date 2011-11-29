Worker = require './worker'

module.exports = Buffer =
  eventTally: 0
  tippingPoint: 3
  events: [
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

  process: (tweet, @jobs) ->
    @tally()
    if @eventTally is @tippingPoint then event = 'holicray'
    else event = @random()
    @queue event, tweet

  random: ->
    randomize = -> return (Math.round(Math.random())-0.5)
    randomEvent = @events.sort @randomize
    event = randomEvent.pop()
    return event

  tally: ->
    @eventTally++
    return @eventTally

  queue: (type, tweet) ->
    Worker.assembleJob type, tweet, @jobs
