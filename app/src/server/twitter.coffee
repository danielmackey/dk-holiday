twitter = require 'ntwitter'
Job = require './job'


#
# ###Twitter config
# TODO: Get production keys with @designkitchen account
#
twitterOptions =
  consumer_key:'hy0r9Q5TqWZjbGHGPfwPjg'
  consumer_secret:'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w'
  access_token_key:'384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq'
  access_token_secret:'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'

tags = [
  'snow'
  'lights'
  'train'
  'discoball'
  'fan'
]

users = [
  'designkitchen'
  'holiduino'
]

twit = new twitter twitterOptions



#
# ##Twitter Streaming
#
#   - Grab tweets @designkitchen
#   - Filter for hashtags. Only tweets with hashtags are caught
#   - Filter for relevancy. Only tweets with hashtags in the tags array are saved
#   - Create a job for each relevant hashtag
#
module.exports = class TwitterStream
  constructor: (@jobs, @logger) ->
    @init()

  init: ->
    twit.stream 'user', track:users, (stream) =>
      @logger.info 'Twitter stream opened', 'following':users

      stream.on 'data', (data) =>
        # The first stream message is an array of friend IDs, ignore it
        unless data.friends? then @filter data

  filter: (data) ->
    hashtags = data.entities.hashtags

    if hashtags.length is 0 then @logger.junk 'Tweet has no hashtags'
    else
      @logger.hold "Tweet has #{hashtags.length} hashtag"

      hashtags.forEach (hashtag, i) =>
        hashtag = hashtag.text

        if tags.indexOf(hashtag) is -1 then @logger.junk "##{hashtag} is irrelevant"
        else
          @logger.save "##{hashtag} job"
          Job.create hashtag, data, @jobs
