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
        twitter:1
        save:2
        connect:3
        disconnect:4
        arduino:5
      colors:
        info:'blue'
        twitter:'cyan'
        save:'green'
        connect:'green'
        disconnect:'red'
        arduino:'cyan'

    logOptions =
      transports:[new (winston.transports.Console)( colorize:true ), new (winston.transports.File)( colorize:true, filename: 'cray.log' )]
      levels:logLevels.levels
      colors:logLevels.colors

    logger = new (winston.Logger)(logOptions)
    winston.addColors logLevels.colors
    return logger
