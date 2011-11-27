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


task 'notes', 'Print out notes from project', ->
  notes = new Notes "#{__dirname}/app"
  notes.annotate()


task 'docs', 'build the docs', (options) ->
  shell 'docco *.coffee'
