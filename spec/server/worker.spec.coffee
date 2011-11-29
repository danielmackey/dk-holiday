Worker = require '../../app/src/server/worker'
Stream = require '../../app/src/server/stream'

describe 'Worker', ->
  it 'assembles and creates a new job', ->
    jobs = {}
    type = 'holicray'
    data =
      text:'Lorem ipsum dolor sit amet'
      user:
        screen_name:'ConanObrien'
        profile_image_url:'http://placehold.it/90x90'

    spyOn Worker, 'createJob'
    Worker.assembleJob type, data, jobs
    expect(Worker.createJob).toHaveBeenCalled()


  it 'processes jobs if arduino is connected', ->

