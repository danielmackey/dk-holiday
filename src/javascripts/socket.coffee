module.exports = class Socket
  constructor: () ->

  init: () ->
    @openSockets()
    @eventsLog '0..10'

  openSockets: ->
    @tweets = $("ul.tweets")
    client = io.connect 'http://localhost:1110/client'
    client.on 'new event', (job) =>
      @tweets.find('li:last-child').remove()
      @tweets.prepend '<li data-tweet="'+job.data.title+'"><a href="http://twitter.com/'+job.data.handle+'">@'+job.data.handle+'</a> just made it <b>'+job.data.hashtag+'</b> in the DK Holiday Room.</li>'

  eventsLog: (pagination) =>
      ajaxOptions =
        url:'http://localhost:1111/jobs/complete/'+pagination+'/desc'
        dataType:'jsonp'
        data:{}
        crossDomain:true
        success:(jobs) => @renderEventsLog jobs
        error:(jqXHR, textStatus, errorThrown) -> console.log jqXHR, textStatus, errorThrown

      $.ajax ajaxOptions

  renderEventsLog: (jobs) ->
    $.each jobs, (i) =>
      @tweets.append "<li data-tweet='#{jobs[i].data.title}'><a href='http://twitter.com/#{jobs[i].data.handle}'>@#{jobs[i].data.handle}</a> just made it <b>#{jobs[i].data.hashtag}</b> in the DK Holiday Room.</li>"

