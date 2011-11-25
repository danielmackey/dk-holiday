module.exports = class Socket
  constructor: () ->

  init: () ->
    @openSockets()
    @eventsLog '0..10'

  openSockets: ->
    @tweets = $("ul.tweets")
    client = io.connect '/'
    client.on 'new event', (job) =>
      @tweets.find('li:last-child').remove()
      @tweets.prepend '<li data-tweet="'+job.data.title+'"><a href="http://twitter.com/'+job.data.handle+'">@'+job.data.handle+'</a> just made it <b>'+job.data.hashtag+'</b> in the DK Holiday Room.</li>'

    client.on 'tally mark', (job) ->
      console.log "tally mark for: #{job.data.hashtag}"


  eventsLog: (pagination) =>
      ajaxOptions =
        url:'/jobs/complete/'+pagination+'/asc'
        dataType:'jsonp'
        data:{}
        crossDomain:true
        success:(jobs) => @renderEventsLog jobs
        error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

      $.ajax ajaxOptions

  renderEventsLog: (jobs) ->
    $.each jobs, (i) =>
      @tweets.append "<li data-tweet='#{jobs[i].data.title}'><a href='http://twitter.com/#{jobs[i].data.handle}'>@#{jobs[i].data.handle}</a> just made it <b>#{jobs[i].data.hashtag}</b> in the DK Holiday Room.</li>"

