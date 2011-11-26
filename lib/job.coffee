module.exports = Job =
  create: (hashtag, data, jobs) ->
    jobData =
      title:data.text
      handle:data.user.screen_name
      avatar:data.user.profile_image_url
      hashtag:hashtag

    jobs.create(hashtag, jobData).attempts(3).save()
