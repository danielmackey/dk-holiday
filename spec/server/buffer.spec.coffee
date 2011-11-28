Buffer = require '../../app/src/server/buffer'

Worker = {}
Worker.reachTippingPoint = -> return
Worker.addTallyMark = -> return

thresholds =
  foo:1
  bar:2
  baz:3

tally = (key) ->
  tips = thresholds[key]
  if Buffer tips then Worker.reachTippingPoint()
  else Worker.addTallyMark()


describe 'Buffer with no threshold', ->
  it 'has no threshold', ->
    spyOn Worker, 'reachTippingPoint'
    tally 'foo'
    expect(Worker.reachTippingPoint).toHaveBeenCalled()

describe 'Buffer tally mark', ->
  it 'adds a tally mark', ->
    spyOn Worker, 'addTallyMark'
    tally 'baz'
    expect(Worker.addTallyMark).toHaveBeenCalled()

describe 'Buffer tipping point', ->
  beforeEach ->
    tally 'bar'

  it 'reaches the tipping point', ->
    spyOn Worker, 'reachTippingPoint'
    tally 'bar'
    expect(Worker.reachTippingPoint).toHaveBeenCalled()
