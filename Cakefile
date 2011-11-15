fs = require 'fs'
sys = require 'sys'
knox = require 'knox'
colors = require 'colors'
stitch = require 'stitch'
cssmin = require 'clean-css'
jsmin = require 'uglify-js'
exec = require('child_process').exec

status = (error, stdout, stderr) -> sys.puts stdout

task 'deploy', 'Upload assets to S3', ->
  s3Options =
    key: ''
    secret: ''
    bucket: ''

  client = knox.createClient s3Options

  assets = []

  assets.forEach (file, i) ->
    fs.readFile "public/#{file}", (err, buf) ->
      reqOptions =
        'Content-Length':buf.length
        'Content-Type':'text/plain'

      req = client.put "/#{file}", reqOptions
      req.on 'response', (res) ->
        if res.statusCode is 200
          sys.puts("#{"✓ saved to".green} #{req.url.cyan.underline}")
      req.end buf
