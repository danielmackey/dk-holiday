Socket = require 'socket'
Stats = require 'stats'


#
# ####Initialize the Client App
#
#   - Open a websocket for communication with the server
#
module.exports = Client =
  init: () ->
    `
    twttr.anywhere(function (T) {
      T("#tweet-box").tweetBox({
        height:75,
        label:'',
        width:630,
        defaultContent:""
      });
    });
    `
    new Socket()
    Stats.refresh()
    @holidaysPast()

  holidaysPast: ->
    $("a#see-past-holidays").bind 'click', (e) ->
      e.preventDefault()
      $("#overlay").show()
      $("#holidays-past #video").html Client.eightEmbed()

    $("#shade").bind 'click', ->
      $("#overlay").hide()

    $("#holidays-past ul.playlist li a").bind 'click', ->
      year = $(this).attr 'id'
      if year is '2008' then video = Client.eightEmbed()
      else video = Client.tenEmbed()
      $("#holidays-past #video").html video

  eightEmbed: ->
    return '<iframe width="650" height="400" src="http://www.youtube.com/embed/z2XUgE6g7XU?rel=0" frameborder="0" allowfullscreen></iframe>'

  tenEmbed: ->
    return '<iframe width="650" height="400" src="http://www.youtube.com/embed/2Z4m4lnjxkY?rel=0" frameborder="0" allowfullscreen></iframe>'
