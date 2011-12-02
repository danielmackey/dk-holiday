# - tweets til next holicray - eventTally websocket
# - total tweets: GET /jobs/complete/0..1/desc.id
# - total holicrays - GET /jobs/holicray/complete/0..1/desc.id
# - just made it ______ GET /jobs/complete/0..1/desc
# - queue - GET /jobs/inactive/0..10/asc
# - history - GET /jobs/complete/1..11/desc

module.exports = Stats =
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

  getTotalTweets: ->
    ajaxOptions =
      url:'/stats'
      dataType:'jsonp'
      data:{}
      crossDomain:true
      success:(stats) => Stats.renderTotalTweets stats
      error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

    $.ajax ajaxOptions

  renderTotalTweets: (stats) ->
    totalTweets = $ "#stats #total-tweets span"
    totalTweets.text stats.completeCount

  getTotalHolicrays: ->
    ajaxOptions =
      url:'/jobs/holicray/complete/0..10000/desc'
      dataType:'jsonp'
      data:{}
      crossDomain:true
      success:(jobs) => Stats.renderTotalHolicrays jobs
      error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

    $.ajax ajaxOptions

  renderTotalHolicrays: (jobs) ->
    totalHolicrays = $ "#stats #total-holicrays span"
    totalHolicrays.text jobs.length

  getLatest: ->
    ajaxOptions =
      url:"/jobs/complete/0..10000/asc"
      dataType:'jsonp'
      data:{}
      crossDomain:true
      success:(jobs) => Stats.renderLatest jobs
      error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

    $.ajax ajaxOptions

  renderLatest: (jobs) ->
    latest = $ "#stats #latest"
    job = jobs.pop()
    template = _.template $("#latest-item").html()
    latest.html template job


  #TODO: refactor history to paginate like https://gist.github.com/4a873b4355ab936ae0e9
  getHistory: (pagination) =>
    ajaxOptions =
      url:"/jobs/complete/#{pagination}/desc"
      dataType:'jsonp'
      data:{}
      crossDomain:true
      success:(jobs) => Stats.renderHistory jobs
      error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

    $.ajax ajaxOptions


  renderHistory: (jobs) ->
    jobs = jobs.slice 1, jobs.length
    if jobs.length <= 9 then $("#history a").hide()
    history = $("#history ul")
    template = _.template $("#history-item").html()
    $.each jobs, (i) =>
      history.append(template(jobs[i]))


  getQueue: (pagination) =>
    ajaxOptions =
      url:"/jobs/inactive/#{pagination}/asc"
      dataType:'jsonp'
      data:{}
      crossDomain:true
      success:(jobs) => Stats.renderQueue jobs
      error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

    $.ajax ajaxOptions


  renderQueue: (jobs) ->
    if jobs.length <= 10 then $("#up-next a").hide()
    queue = $("#up-next ul")
    template = _.template $("#queue-item").html()
    $.each jobs, (i) =>
      queue.append template jobs[i]

  loadMoreHistory: () ->
    $("#history a.load-more").bind 'click', (e) =>
      e.preventDefault()
      from = $(e.currentTarget).attr 'data-from'
      to = $(e.currentTarget).attr 'data-to'
      @getHistory "#{from}..#{to}"
      $(e.currentTarget).attr 'data-from', from + 10
      $(e.currentTarget).attr 'data-to', to + 10
