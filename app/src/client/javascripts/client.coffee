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
