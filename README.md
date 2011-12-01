###Setup

  `npm install`

  `npm install -g coffee-script`

  `npm install -g jasmine-node`

  `brew install foreman`

  `brew install redis`

##Development

  `foreman start`

##App Workflow

   - Stream
     - Open and listen for @designkitchen tweets
     - Open websocket
     - Emit all tweets and send to Buffer

   - Buffer
     - Keep tally of each tweet
     - Assign a random event or holicray event if tipping point is reached
     - Create a new job with type of event and emit new job

   - Worker
     - Tick through jobs and emit current job
     - Call arduino and wait for callback
     - On callback, next job is processed
     - Emit completed job/new event


## Module Interfaces

  - Stream at the front, only interfaces with Worker
  - Worker sits between Stream and Buffer
  - Buffer works behind the scenes and only interfaces with Worker
