Util = require 'utility'

_.templateSettings =
  interpolate:/\{\{(.+?)\}\}/g

module.exports = Stats =
  el:
    totalTweets:$ "#total-tweets-number"
    totalHolicrays:$ "#total-crays-number"
    latest:$ "#current-tweet"
    history:$ "#history ul"
    queue:$ "#up-next ul"
    tallyCount: $ "#tweet-counter"
    tallyMeter:$ "#full-inner"

  historyFrom:11
  historyTo:21

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
    @getQueue()
    @clickMoreHistory()

  getStats: (url, callback) ->
    ajaxOptions =
      url:"#{url}"
      dataType:'jsonp'
      data:{}
      cache:false
      crossDomain:true
      success:(stats) => callback stats
    $.ajax ajaxOptions


  getTotalTweets: ->
    @getStats '/stats', Stats.renderTotalTweets

  renderTotalTweets: (stats) ->
    Stats.el.totalTweets.text stats.completeCount
    Stats.renderCrayTally stats.completeCount
    Stats.getLatest stats.completeCount
    Stats.getHistory stats.completeCount


  getTotalCrays: ->
    @getStats '/jobs/it%20Holicray!/complete/0..10000/desc', Stats.renderTotalCrays

  renderTotalCrays: (jobs) ->
    Stats.el.totalHolicrays.text jobs.length


  getLatest: (latest) ->
    @getStats "/job/#{latest + 5}", Stats.renderLatest

  renderLatest: (job) ->
    template = _.template $("#latest-tpl").html()
    job.data.id = job.id
    latest = template job.data
    Stats.el.latest.empty().html latest


  getHistory: (count) ->
    @getStats "/job/#{count + 6}", Stats.renderHistory

  renderHistory: (job) ->
    template = _.template $("#history-tpl").html()
    Stats.el.history.empty()
    id = job.id
    job.data.id = id
    item = template job.data
    Stats.el.history.append item
    Stats.tweetTooltips()

  getMoreHistory: ->
    @getStats "/jobs/complete/0..10000/desc", Stats.renderMoreHistory

  renderMoreHistory: (jobs) ->
    jobs = jobs.slice Stats.historyFrom, Stats.historyTo
    Stats.historyFrom = Stats.historyFrom + 10
    Stats.historyTo = Stats.historyTo + 10
    if jobs.length < 10 then $("#history a.load-more").hide()
    template = _.template $("#history-tpl").html()
    _.each jobs, (job) =>
      id = job.id
      job.data.id = id
      item = template job.data
      Stats.el.history.append item
      Stats.tweetTooltips()

  getQueue: ->
    @getStats "/jobs/delayed/0..9/asc", Stats.renderQueue

  renderQueue: (jobs) ->
    if jobs.length < 10 then $("#up-next a").hide()
    template = _.template $("#queue-tpl").html()
    Stats.el.queue.empty()
    _.each jobs, (job) =>
      job.data.id = job.id
      item = template job.data
      Stats.el.queue.append item
      Stats.tweetTooltips()


  clickMoreHistory: () ->
    $('#history a.load-more').bind 'click', (e) =>
      e.preventDefault()
      @getMoreHistory()


  tweetTooltips: ->
    options =
      content:
        attr:'data-bind-tweet'
      position:
        my:'bottom center'
        at:'top center'
        adjust:
          y:15
    $("li.title").qtip options
