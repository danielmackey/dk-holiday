###Local Setup

  `$ npm install`

  `$ npm install -g coffee-script`

  `$ npm install -g supervisor`

  `$ brew install redis`


##Development

  `$ /path/to/redis/redis-server`

  `$ supervisor app/server.coffee`


##Tests
  `$ npm install -g jasmine-node`

  `$ cake test`


##Project Notes and To Dos
  `$ cake notes`


##Offline Mode
Restart the app before 9am and after 5pm to switch between on/offline modes


## Tech Inventory

  ###Client-side
    - Moved from jQuery to Zepto, reducing total package size from ~180k to ~70k
    - Underscore.js for utility and templating
    - Socket.io for websocket messaging
    - Jade for view rendering
    - Stylus for style preprocessing
    - CoffeeScript


  ###Server-side
    - Express Web Server
      - Stitch middleware for javascript bundling
      - Stylus middleware for stylesheet bundling

    - App Server
      - Job queue with Kue + Redis
      - Env vars managed with nconf
      - State restoration with node-request /stats
      - Twitter stream with ntwitter

    - Logging with winston
    - Documentation with docco
    - Tests with Jasmine
