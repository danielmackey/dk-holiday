var State, app, compile, connect, express, fs, io, javascripts, jobs, kue, package, path, port, stitch, stylesheets, stylus, viewOptions;
express = require('express');
stylus = require('stylus');
connect = require('connect');
stitch = require('stitch');
kue = require('kue');
fs = require('fs');
path = require('path');
State = require('./src/server/state');
app = express.createServer();
port = 5000;
io = require('socket.io').listen(app);
io.enable('browser client minification');
io.set('authorization', function(handshakeData, callback) {
  return callback(null, true);
});
io.configure('production', function() {
  return io.set('log level', 1);
});
jobs = kue.createQueue();
kue.app.enable("jsonp callback");
kue.app.set('title', 'Queue: Holi-Cray-Matic™ by Designkitchen');
javascripts = {
  paths: ["" + __dirname + "/src/client/javascripts", "" + __dirname + "/src/shared"],
  dependencies: []
};
stylesheets = {
  src: "" + __dirname + "/src/client",
  dest: "" + __dirname + "/public",
  compile: compile
};
compile = function(str, path) {
  return stylus(str)["import"](("" + __dirname + "/src/client/stylesheets").set('filename', path.set('compress', true)));
};
package = stitch.createPackage(javascripts);
viewOptions = {
  locals: {
    title: 'Holi-Cray-Matic™ by Designkitchen'
  },
  layout: 'layout'
};
app.configure(function() {
  app.use(app.router);
  app.use(stylus.middleware(stylesheets));
  app.set('view engine', 'jade');
  return app.set('views', "" + __dirname + "/src/client/views");
});
app.configure('development', function() {
  app.use(express.static("" + __dirname + "/public"));
  return app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});
app.configure('production', function() {
  app.use(express.static("" + __dirname + "/public", {
    maxAge: 31557600000
  }));
  return app.use(express.errorHandler());
});
app.get('/application.js', package.createServer());
app.get('/', function(req, res) {
  return res.render('index', viewOptions);
});
app.use(kue.app);
app.listen(port);
State.restore(jobs, io);