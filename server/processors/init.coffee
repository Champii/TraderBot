bus = require '../bus'

BotResource = require '../resources/BotResource'

exports.init = ->
  bus.on 'tbInit', ->
    BotResource.StopAll (err) ->
      return console.error err if err?

    bus.emit 'startPubTickers'