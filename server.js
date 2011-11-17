var app, client, compile, connect, cssOptions, express, io, jobs, kue, package, port, stitch, stylus, twit, twitter, twitterOptions;
express = require('express');
stylus = require('stylus');
connect = require('connect');
stitch = require('stitch');
twitter = require('ntwitter');
app = express.createServer();
kue = require('kue');
jobs = kue.createQueue();
port = 37895;
io = require('socket.io').listen(app);
package = stitch.createPackage({
  paths: [__dirname + '/src/javascripts'],
  dependencies: []
});
cssOptions = {
  src: "" + __dirname + "/src",
  dest: "" + __dirname + "/public",
  compile: compile
};
compile = function(str, path) {
  return stylus(str)["import"](("" + __dirname + "/src/stylesheets").set('filename', path.set('compress', true)));
};
twitterOptions = {
  consumer_key: 'hy0r9Q5TqWZjbGHGPfwPjg',
  consumer_secret: 'EVFMzimXk1TTDGFYnbEmfiAdUe0uFDt7YrzTujc7w',
  access_token_key: '384683488-xxmO6GV7lNpL5Z0U76djVh3BrFm1msb9yOHG3Vfq',
  access_token_secret: 'cL6y4QIU8e1lwmZNq89I324lDwA62FJ8q2q5aKtM8NI'
};
twit = new twitter(twitterOptions);
client = io.of('/client').on('connection', function(client_socket) {
  var arduino;
  twit.stream('user', {
    track: ['designkitchen', 'holiduino']
  }, function(stream) {
    return stream.on('data', function(data) {
      var hashtags;
      if (data.friends === void 0) {
        hashtags = data.entities.hashtags;
        if (hashtags.length !== 0) {
          return hashtags.forEach(function(hashtag, i) {
            var jobData;
            jobData = {
              title: data.text,
              handle: data.user.screen_name,
              avatar: data.user.profile_image_url,
              hashtag: hashtag.text
            };
            return jobs.create('arduino action', jobData).attempts(3).save();
          });
        }
      }
    });
  });
  return arduino = io.of('/arduino').on('connection', function(arduino_socket) {
    client_socket.emit('arduino connected');
    jobs.process('arduino action', function(job, done) {
      arduino_socket.emit('action assignment', job);
      return done();
    });
    arduino_socket.on('action complete', function(job) {
      return client_socket.emit('new event', job);
    });
    return arduino_socket.on('disconnect', function() {
      return client_socket.emit('arduino disconnected');
    });
  });
});
app.configure(function() {
  app.use(app.router);
  app.use(stylus.middleware(cssOptions));
  app.use(express.static("" + __dirname + "/public"));
  app.get('/application.js', package.createServer());
  return app.get('/', function(req, res) {
    return res.sendfile("" + __dirname + "/public/index.html");
  });
});
app.listen(port);
kue.app.enable("jsonp callback");
kue.app.set('title', 'DK Holiday');
kue.app.listen("" + (port + 1));
console.log("App server started on port: " + port + ", Queue server started on port: " + (port + 1));