threshold =
  'snow':10
  'lights':1
  'train':10

count =
  'snow':0
  'lights':0
  'train':0

#
# ##Give Buffer a job, a socket to update, and a callback
#

module.exports = Buffer =
  run:(@job, @socket, @callback) ->
    action = @job.data.hashtag

    counter = (i) ->
      count[i] = count[i]++

    counter(action)

    if count[action] is threshold[action]
      @socket.emit 'action assignment', @job
      count[action] = 0

    @callback()
