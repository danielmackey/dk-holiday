winston = require 'winston'

#
# ###Logging config
#
#   - Use [winston](https://github.com/flatiron/winston) on the console with custom log levels and coloring
#   - Write log to cray.log
#
module.exports = class Logger
  constructor: () ->
    @logger = @init()
    return @logger

  init: () ->
    logLevels =
      levels:
        info:0
        junk:1
        alert:2
        tally:3
        arduino:4
        connect:5
        disconnect:6
        hold:7
        save:8
        confirm:9
        twitter:10
      colors:
        info:'blue'
        junk:'yellow'
        alert:'red'
        tally:'cyan'
        arduino:'cyan'
        connect:'green'
        disconnect:'red'
        hold:'cyan'
        save:'green'
        confirm:'green'
        twitter:'cyan'

    logOptions =
      transports:[new (winston.transports.Console)( colorize:true ), new (winston.transports.File)( colorize:true, filename: 'cray.log' )]
      levels:logLevels.levels
      colors:logLevels.colors

    logger = new (winston.Logger)(logOptions)
    winston.addColors logLevels.colors
    return logger
