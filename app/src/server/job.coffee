#
# ####Create a Job
#
#   - Assemble the job data object
#   - Create a new job with the data using [kue](https://github.com/LearnBoost/kue)
#   - Log job complete, job failed, and progress for long-running jobs
#
module.exports = Job =
  create: (hashtag, data, jobs) ->
    jobData =
      title:data.text
      handle:data.user.screen_name
      avatar:data.user.profile_image_url
      hashtag:hashtag

    job = jobs.create(hashtag, jobData).attempts(3).save()

    job.on('complete', -> console.log "Job complete").on('failed', -> console.log "Job failed").on 'progress', (progress) -> process.stdout.write('\r  job #' + job.id + ' ' + progress + '% complete')
