#
# ####Client Websocket
#
#   - Listen for the 'new event' message
#   - Listen for the 'tally mark' message and confirm reception
#
module.exports = class Socket
  constructor: () ->

  init: () ->
    @openSocket()
    @eventsLog '0..10'

  openSocket: ->
    @tweets = $("ul.tweets")
    @now = $("#right-now")
    client = io.connect '/arduino'

    client.on 'new event', (job) =>
      @tweets.find('li:last-child').remove()
      @tweets.prepend '<li data-tweet="'+job.data.title+'"><a href="http://twitter.com/'+job.data.handle+'">@'+job.data.handle+'</a> just made it <b>'+job.data.event+'</b> in the DK Holiday Room.</li>'

    client.on 'right now', (job) =>
      @now.find('img').attr 'src', job.data.avatar
      @now.find('p span.handle').text "@#{job.data.handle}: "
      @now.find('p span.tweet').text job.data.title

    client.on 'new tweet', (tweet) ->
      humane.success ["<h3>Just now:</h3>","<b>@#{tweet.user.screen_name}:</b> #{tweet.text}"]
      humane.timeout = 7000


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
      @tweets.append "<li data-tweet='#{jobs[i].data.title}'><small style='font-size:8px'>#{jobs[i].updated_at}</small><a href='http://twitter.com/#{jobs[i].data.handle}'>@#{jobs[i].data.handle}</a> just made it <b>#{jobs[i].data.event}</b> in the DK Holiday Room.</li>"

