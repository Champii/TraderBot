_ = require 'underscore'

Settings = require 'settings'

config = new Settings require '../../settings/config'

class Log

  constructor: ->

  Log: ->
    if config.log >= 3
      console.log.apply undefined, _(arguments).map (value) -> value

  Warning: (mess) ->
    if config.log >= 2
      console.log.apply undefined, _(arguments).map (value) -> value

  Error: (mess) ->
    if config.log >= 1
      console.error.apply undefined, _(arguments).map (value) -> value

module.exports = new Log
