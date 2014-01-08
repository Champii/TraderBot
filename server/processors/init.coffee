bus = require '../bus'
log = require '../util/Log'

BotResource = require '../resources/BotResource'

exports.init = ->
  bus.on 'tbInit', ->
    BotResource.StopAll (err) ->
      return log.Error err if err?

      bus.emit 'startPubTickers'