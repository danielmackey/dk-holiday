module.exports = Job =
  create: (hashtag, data, jobs) ->
    jobData =
      title:data.text
      handle:data.user.screen_name
      avatar:data.user.profile_image_url
      hashtag:hashtag

    job = jobs.create(hashtag, jobData).attempts(3).save()

    job.on('complete', -> console.log "Job complete").on('failed', -> console.log "Job failed").on 'progress', (progress) -> process.stdout.write('\r  job #' + job.id + ' ' + progress + '% complete')
