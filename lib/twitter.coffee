twitter = require 'ntwitter'



#
# ###Twitter config
# TODO: Get production keys with @designkitchen account
#
#   - Pluck tweets with hashtags that exist in the tags array
#   - Follow @designkitchen for production and @holiduino during development
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
# ##Streaming
#
#   - Grab tweets @designkitchen
#   - Filter for hashtags. Only tweets with hashtags are caught
#   - Filter for relevancy. Only tweets with hashtags in the tags array are saved
#   - Create a job for each relevant hashtag
#
module.exports = TwitterStream =
  init: (jobs, logger) ->
    twit.stream 'user', track:users, (stream) ->
  	  logger.info 'Twitter stream opened', 'following':users
  	  stream.on 'data', (data) ->
  	    if data.friends is undefined # The first stream message is an array of friend IDs, ignore it
  	      hashtags = data.entities.hashtags

  	      if hashtags.length is 0
  	        logger.junk 'Tweet has no hashtags'
  	      else
  	        logger.hold "Tweet has #{hashtags.length} hashtag"
  	        hashtags.forEach (hashtag, i) ->
  	          hashtag = hashtag.text
  	          if tags.indexOf(hashtag) is -1
  	            logger.junk "##{hashtag} is irrelevant"
  	          else
  	            logger.save "##{hashtag} job"
  	            jobData =
  	              title:data.text
  	              handle:data.user.screen_name
  	              avatar:data.user.profile_image_url
  	              hashtag:hashtag

  	            jobs.create(hashtag, jobData).attempts(3).save()
