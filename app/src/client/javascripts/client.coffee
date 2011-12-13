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
        defaultContent:"@designkitchen #holicray"
      });
    });
    `
    window.socket = new Socket()
    Stats.refresh()
    @holidaysPast()
    @shareFacebook()
    @shareTwitter()

  shareTwitter: ->
    status = 'Every%20tweet%20at%20%40designkitchen%20sets%20off%20the%20Holi-Cray-Matic%E2%84%A2%20in%20one%20of%20our%20conference%20rooms.%20Watch%20it%20live%20at%20http%3A%2F%2Fholiday.designkitchen.com'
    $("a.share.twitter").bind 'click', (e) ->
      e.preventDefault()
      window.open "http://twitter.com/intent/tweet?source=holicraymaker&text=#{status}",'twitter','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=300,width=400'


  shareFacebook: ->
    $("a.share.facebook").bind 'click', (e) ->
      e.preventDefault()
      fbOptions =
        method: 'feed',
        message: 'getting educated about Facebook Connect',
        name: 'Holi-Cray-Matic™ by Designkitchen',
        link: 'http://holiday.designkitchen.com',
        picture: 'http://holiday.designkitchen.com/images/share.jpg',
        description: 'Every tweet @ designkitchen sets off the Holi-Cray-Matic™ in one of our conference rooms. Watch it live at http://holiday.designkitchen.com'
      FB.ui fbOptions

  holidaysPast: ->
    $("a#see-past-holidays").bind 'click', (e) ->
      e.preventDefault()
      $("#overlay").show()
      $("#holidays-past #video").html Client.eightEmbed()

    $("#shade, a.close").bind 'click', ->
      $("#overlay").hide()

    $("#holidays-past ul.playlist li a:not(.close)").bind 'click', ->
      year = $(this).attr 'id'
      $("ul.playlist li a").removeClass 'active'
      $(this).addClass 'active'
      if year is '2008' then video = Client.eightEmbed()
      else video = Client.tenEmbed()
      $("#holidays-past #video").html video

  tenEmbed: ->
    return '<iframe width="650" height="400" src="http://player.vimeo.com/video/33534497?title=0&amp;byline=0&amp;portrait=0" frameborder="0" allowfullscreen></iframe>'

  eightEmbed: ->
    return '<iframe width="650" height="400" src="http://player.vimeo.com/video/33538059?title=0&amp;byline=0&amp;portrait=0" frameborder="0" allowfullscreen></iframe>'

  crayTally:0

  goCray: ->
    crayStyles = '
      <style type="text/css" id="cray-styles">
        .red { color:#59AB4B!important; }
        .green { color #D64622!important; }
      </style>
    '
    $("#hidden-animations > div").addClass 'animate'
    $("a.dk-button").css 'background-image', 'url(/images/from-us.gif)'
    $("body").css 'background-image','url(/images/bg2.gif)'
    $("body").append crayStyles
    Client.crayTally++

    again = () ->
      unless Client.crayTally is 10
        Client.goCray()
      else
        $("#hidden-animations > div").removeClass 'animate'
        $("a.dk-button").css 'background-image', 'url(/images/dk-button.png)'
        $("body").css 'background-image', 'url(/images/bg.gif)'

    timer = () ->
      $('#cray-styles').remove()
      setTimeout again, 500

    setTimeout timer, 500
