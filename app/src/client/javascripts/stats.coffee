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

  newEvent: ->
    console.log 'refresh stats'

  crayTally: ->
    console.log 'update cray meter'

  init: ->
    @getTotalTweets()
    @getTotalHolicrays()
    @getLatest()
    @getHistory '0..10000'
    @getQueue '0..9'
    @loadMoreHistory()

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


  getTotalHolicrays: ->
    @getStats '/jobs/holicray/complete/0..10000/desc', Stats.renderTotalHolicrays

  renderTotalHolicrays: (jobs) ->
    Stats.el.totalHolicrays.text jobs.length


  getLatest: ->
    @getStats "/jobs/complete/0..10000/asc", Stats.renderLatest

  renderLatest: (jobs) ->
    job = jobs.pop()
    template = _.template $("#latest-item").html()
    Stats.el.latest.html template job


  #TODO: refactor history to paginate like https://gist.github.com/4a873b4355ab936ae0e9
  getHistory: (pagination) ->
    @getStats "/jobs/complete/#{pagination}/desc", Stats.renderHistory

  renderHistory: (jobs) ->
    jobs = jobs.slice 1, 10
    template = _.template $("#history-item").html()
    $.each jobs, (i) =>
      Stats.el.history.append template jobs[i]


  getQueue: (pagination) ->
    @getStats "/jobs/inactive/#{pagination}/asc", Stats.renderQueue

  renderQueue: (jobs) ->
    if jobs.length <= 10 then $("#up-next a").hide()
    template = _.template $("#queue-item").html()
    $.each jobs, (i) =>
      Stats.el.queue.append template jobs[i]


  loadMoreHistory: () ->
    $("#history a.load-more").bind 'click', (e) =>
      e.preventDefault()
      from = $(e.currentTarget).attr 'data-from'
      to = $(e.currentTarget).attr 'data-to'
      @getHistory "#{from}..#{to}"
      $(e.currentTarget).attr 'data-from', from + 10
      $(e.currentTarget).attr 'data-to', to + 10
