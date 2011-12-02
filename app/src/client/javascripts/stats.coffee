# - tweets til next holicray - eventTally websocket
# - total tweets: GET /jobs/complete/0..1/desc.id
# - total holicrays - GET /jobs/holicray/complete/0..1/desc.id
# - just made it ______ GET /jobs/complete/0..1/desc
# - queue - GET /jobs/inactive/0..10/asc
# - history - GET /jobs/complete/1..11/desc

module.exports = Stats =
  el:
    totalTweets:$ "#total-tweets-number"
    totalHolicrays:$ "#total-crays-number"
    latest:$ "#current-tweet"
    history:$ "#history ul"
    queue:$ "#up-next ul"
    tweetCount: $ "#tweet-counter"

  historyFrom:1
  historyTo:11

  # TODO: Test newEvent() and animateMeter() with new tweets
  newEvent: ->
    console.log 'refresh stats and animate meter'
    @refresh()
    preTally = parseInt @el.tweetCount, 10
    postTally = preTally--
    @el.tweetCount.text postTally
    @animateMeter()

  animateMeter: ->
    bar = $ "#full-inner"
    startingWidth = bar.width()
    totalWidth =$("#full-bar").width()
    increment = totalWidth / 40
    bar.css 'width', startingWidth + increment



  refresh: ->
    @getTotalTweets()
    @getTotalCrays()
    @getLatest()
    @getHistory()
    @getQueue '0..9'
    @clickMoreHistory()

  getStats: (url, callback) ->
    ajaxOptions =
      url:url
      dataType:'jsonp'
      data:{}
      crossDomain:true
      success:(stats) => callback stats
      error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown
    $.ajax ajaxOptions


  getTotalTweets: ->
    @getStats '/stats', Stats.renderTotalTweets

  renderTotalTweets: (stats) ->
    Stats.el.totalTweets.text stats.completeCount


  getTotalCrays: ->
    @getStats '/jobs/holicray/complete/0..10000/desc', Stats.renderTotalCrays

  renderTotalCrays: (jobs) ->
    Stats.el.totalHolicrays.text jobs.length


  getLatest: ->
    @getStats "/jobs/complete/0..10000/asc", Stats.renderLatest

  renderLatest: (jobs) ->
    job = jobs.pop()
    template = _.template $("#latest-item").html()
    Stats.el.latest.html template job


  getHistory: ->
    @getStats "/jobs/complete/0..10000/desc", Stats.renderHistory

  renderHistory: (jobs) ->
    jobs = jobs.slice Stats.historyFrom, Stats.historyTo
    Stats.historyFrom = Stats.historyFrom + 10
    Stats.historyTo = Stats.historyTo + 10
    if jobs.length <= 9 then $("#history a.load-more").hide()
    template = _.template $("#history-item").html()
    $.each jobs, (i) =>
      Stats.el.history.append template jobs[i]

  getMoreHistory: ->
    @getHistory()


  getQueue: (pagination) ->
    @getStats "/jobs/inactive/#{pagination}/asc", Stats.renderQueue

  renderQueue: (jobs) ->
    if jobs.length <= 10 then $("#up-next a").hide()
    template = _.template $("#queue-item").html()
    $.each jobs, (i) =>
      Stats.el.queue.append template jobs[i]


  clickMoreHistory: () ->
    $("#history a.load-more").bind 'click', (e) =>
      e.preventDefault()
      @getMoreHistory()
