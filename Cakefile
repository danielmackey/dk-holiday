{spawn, exec} = require 'child_process'
{log, error} = console; print = log
Notes = require 'notes'
fs = require 'fs'
sys = require 'sys'
colors = require 'colors'

shell = (cmds, callback) ->
    cmds = [cmds] if Object::toString.apply(cmds) isnt '[object Array]'
    exec cmds.join(' && '), (err, stdout, stderr) ->
        print trimStdout if trimStdout = stdout.trim()
        error stderr.trim() if err
        callback() if callback

task 'build', 'Compile the server', ->
  shell "coffee -c --bare app/server.coffee"

task 'notes', 'Print out notes from project', ->
  notes = new Notes "#{__dirname}/app"
  notes.annotate()

task 'test', 'Test the app', (options) ->
  shell "jasmine-node --coffee spec"

task 'docs', 'build the docs', (options) ->
  shell "docco #{__dirname}/app/*.coffee #{__dirname}/app/src/server/*.coffee #{__dirname}/app/src/client/javascripts/*.coffee"
