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


## Tech Inventory

  ### Client-side
    - Moved from jQuery to Zepto, reducing total package size from ~180k to ~70k
    - Plates.js for clean templating
    - Underscore.js for utility
    - Socket.io for websocket messaging
    - Jade for view rendering
    - Stylus for style preprocessing
    - CoffeeScript


  ### Server-side
    - Express Web Server
      - Stitch middleware for javascript bundling
      - Stylus middleware for stylesheet bundling

    - App Server
      - Job queue with Kue + Redis
      - Env vars managed with nconf
      - State restoration with node-request /stats
      - Twitter stream with ntwitter

    - Logging with winston and Loggly
    - Documentation with docco
    - Tests with Jasmine
