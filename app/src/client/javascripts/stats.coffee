#TODO: Get stats from kue for frontend

# - tweets til next holicray - eventTally websocket
# - total tweets: GET /jobs/complete/0..1/desc.id
# - total holicrays - GET /jobs/holicray/complete/0..1/desc.id
# - just made it ______ GET /jobs/complete/0..1/desc
# - queue - GET /jobs/inactive/0..10/asc
# - history - GET /jobs/complete/1..11/desc

module.exports = Stats =
  newEvent: ->
    console.log 'new event'

  crayTally: ->
    console.log 'cray tally'

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
    latest.html "<p><small>#{job.id}</small> #{job.data.title}</p>"

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
    $.each jobs, (i) =>
      history.append "<li data-tweet='#{jobs[i].data.title}'><small style='font-size:8px'>#{jobs[i].id}</small><a href='http://twitter.com/#{jobs[i].data.handle}'>@#{jobs[i].data.handle}</a> just made it <b>#{jobs[i].data.event}</b> in the DK Holiday Room.</li>"


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
    $.each jobs, (i) =>
      queue.append "<li data-tweet='#{jobs[i].data.title}'><small style='font-size:8px'>#{jobs[i].id}</small><a href='http://twitter.com/#{jobs[i].data.handle}'>@#{jobs[i].data.handle}</a> just made it <b>#{jobs[i].data.event}</b> in the DK Holiday Room.</li>"

  loadMoreHistory: () ->
    $("#history a.load-more").bind 'click', (e) =>
      e.preventDefault()
      from = $(e.currentTarget).attr 'data-from'
      to = $(e.currentTarget).attr 'data-to'
      @getHistory "#{from}..#{to}"
      $(e.currentTarget).attr 'data-from', from + 10
      $(e.currentTarget).attr 'data-to', to + 10
