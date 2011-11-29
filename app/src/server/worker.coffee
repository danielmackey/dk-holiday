module.exports = Worker =
  assembleJob: (type, data, jobs) ->
    jobData =
      title:data.text
      handle:data.user.screen_name
      avatar:data.user.profile_image_url
      event:type

    Worker.createJob type, jobData, jobs


  createJob: (type, jobData, jobs) ->
    job = jobs.create(type, jobData).attempts(3).save()
    job.on 'complete', -> console.log "Job complete"


  processJobs: (socket, jobs, logger) ->
    #
    # ### Job processor
    #
    #   - Emit a new job to arduino
    #   - Emit a right now message
    #   - Wait for callback of completed job
    #   - Emit a new event and finish job
    #
    process = (job, done) =>
      logger.arduino "##{job.data.event} by @#{job.data.handle}"
      socket.emit 'action assignment', job, (completedJob) =>
        logger.confirm 'Arduino action', 'event':completedJob.data.event
        socket.emit 'new event', completedJob
        done()


    # #### Define a job process for each event
    jobs.process 'snow', (job, done) ->
      process job, done

    jobs.process 'lights', (job, done) ->
      process job, done

    jobs.process 'train', (job, done) ->
      process job, done

    jobs.process 'discoball', (job, done) ->
      process job, done

    jobs.process 'holicray', (job, done) ->
      process job, done
