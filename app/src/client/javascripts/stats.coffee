#FIXME: Latest event appends instead of replaces on newEvent()
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

  animateMeter: ->
    startingWidth = @el.tallyMeter.width()
    totalWidth =$("#full-bar").width()
    increment = totalWidth / 40
    @el.tallyMeter.css 'width', startingWidth + increment

  resetMeter: ->
    @el.tallyMeter.css 'width', '0px'

  renderCrayTally: (count) ->
    factorForty = (n) ->
      if n < 41 then return n
      else
        timesOver = parseInt n / 40, 10
        extra = timesOver * 40
        return n - extra

    tally = factorForty count
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
    Stats.renderCrayTally stats.completeCount


  getTotalCrays: ->
    @getStats '/jobs/holicray/complete/0..10000/desc', Stats.renderTotalCrays

  renderTotalCrays: (jobs) ->
    Stats.el.totalHolicrays.text jobs.length


  getLatest: ->
    @getStats "/jobs/complete/0..10000/asc", Stats.renderLatest

  renderLatest: (jobs) ->
    job = jobs.pop()
    tpl = Stats.el.latest.html()
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
    tpl = Stats.el.history.html().split('</li>')[0]
    $.each jobs, (i) =>
      jobs[i].data.id = jobs[i].id
      item = Plates.bind tpl, jobs[i].data, map
      Stats.el.history.append item

    Stats.el.history.find('li:first-child').hide()

  getMoreHistory: ->
    @getHistory()


  getQueue: (pagination) ->
    @getStats "/jobs/inactive/#{pagination}/asc", Stats.renderQueue

  renderQueue: (jobs) ->
    if jobs.length <= 9 then $("#up-next a").hide()
    map =
      "event":"class"
      "title":["class","data-bind-tweet"]
      "handle":"class"
      "id":"class"
    tpl = Stats.el.queue.html().split('</li>')[0]
    $.each jobs, (i) =>
      jobs[i].data.id = jobs[i].id
      item = Plates.bind tpl, jobs[i].data, map
      Stats.el.queue.append item

    Stats.el.queue.find('li:first-child').hide()

  clickMoreHistory: () ->
    $("#history a.load-more").bind 'click', (e) =>
      e.preventDefault()
      @getMoreHistory()
