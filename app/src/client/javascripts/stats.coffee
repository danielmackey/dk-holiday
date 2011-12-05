Util = require 'utility'

module.exports = Stats =
  el:
    totalTweets:$ "#total-tweets-number"
    totalHolicrays:$ "#total-crays-number"
    latest:$ "#current-tweet"
    history:$ "#history ul"
    queue:$ "#up-next ul"
    tallyCount: $ "#tweet-counter"
    tallyMeter:$ "#full-inner"

  historyFrom:1
  historyTo:11

  newEvent: ->
    @refresh()

  renderCrayTally: (count) ->
    tally = Util.factorForty count
    @el.tallyCount.text "#{40 - tally}"

    startingWidth = @el.tallyMeter.width()
    totalWidth =$("#full-bar").width()
    increment = totalWidth / 40
    width = tally * increment
    @el.tallyMeter.css 'width', width


  refresh: ->
    @getTotalTweets()
    @getTotalCrays()
    @getLatest()
    @getHistory()
    @getQueue()
    @clickMoreHistory()

  getStats: (url, callback) ->
    ajaxOptions =
      url:"#{url}?callback=?"
      type:'jsonp'
      data:{}
      success:(stats) => callback stats
    $.ajax ajaxOptions


  getTotalTweets: ->
    @getStats '/stats', Stats.renderTotalTweets

  renderTotalTweets: (stats) ->
    Stats.el.totalTweets.text stats.completeCount
    Stats.renderCrayTally stats.completeCount


  getTotalCrays: ->
    @getStats '/jobs/holicray/complete/0..10000/desc', Stats.renderTotalCrays

  renderTotalCrays: (jobs) ->
    Stats.el.totalHolicrays.text jobs.length


  getLatest: ->
    @getStats "/jobs/complete/0..10000/asc", Stats.renderLatest

  renderLatest: (jobs) ->
    job = jobs.pop()
    tpl = $("#latest-tpl").html()
    map =
      "event":"class"
      "title":"class"
      "handle":"class"
      "id":"class"
    job.data.id = job.id
    latest = Plates.bind tpl, job.data, map
    Stats.el.latest.html latest


  getHistory: ->
    @getStats "/jobs/complete/0..10000/desc", Stats.renderHistory

  renderHistory: (jobs) ->
    jobs = jobs.slice Stats.historyFrom, Stats.historyTo
    Stats.historyFrom = Stats.historyFrom + 10
    Stats.historyTo = Stats.historyTo + 10
    if jobs.length <= 9 then $("#history a.load-more").hide()
    map =
      "event":"class"
      "title":["class","data-bind-tweet"]
      "handle":"class"
      "id":"class"
    tpl = $("#history-tpl").html()
    _.each jobs, (job) =>
      job.data.id = job.id
      item = Plates.bind tpl, job.data, map
      Stats.el.history.append item

  getMoreHistory: ->
    @getHistory()


  getQueue: ->
    @getStats "/jobs/delayed/0..9/asc", Stats.renderQueue

  renderQueue: (jobs) ->
    if jobs.length <= 9 then $("#up-next a").hide()
    map =
      "event":"class"
      "title":["class","data-bind-tweet"]
      "handle":"class"
      "id":"class"
    tpl = $("#queue-tpl").html()
    _.each jobs, (job) =>
      job.data.id = job.id
      item = Plates.bind tpl, job.data, map
      Stats.el.queue.append item


  clickMoreHistory: () ->
    $('#history a.load-more').bind 'click', (e) =>
      e.preventDefault()
      @getMoreHistory()

