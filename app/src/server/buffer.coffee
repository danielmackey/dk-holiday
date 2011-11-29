Worker = require './worker'

eventTally = 0
tippingPoint = 3

module.exports = Buffer =
  events: [
    'snow'
    'lights'
    'train'
    'discoball'
    'fan'
  ]

  process: (tweet, @jobs) ->
    @tally()
    if eventTally is tippingPoint then event = 'holicray'
    else event = @random()
    @queue event, tweet

  random: ->
    randomize = -> return (Math.round(Math.random())-0.5)
    randomEvent = @events.sort @randomize
    event = randomEvent.pop()
    return event

  tally: ->
    eventTally++
    return eventTally

  queue: (type, tweet) ->
    Worker.createJob type, tweet, @jobs
