_ = require 'underscore'

bus = require '../bus'
BotResource = require '../resources/BotResource'
TraderBot = require '../trader/TraderBot'

bots = []

exports.init = ->

  bus.on 'botStart', (id) ->
    if _(bots).findWhere {id: id}
      return

    BotResource.Fetch id, (err, bot) ->
      return console.error err if err?

      newBot = new TraderBot bot
      console.log 'Bot Start : ', id
      newBot.Run (err) ->
        console.log 'Bot Running : ', id
        return console.error err if err?
        # bot.active = true
        bot.Save (err, bot) ->
          return console.error err if err

          bots.push newBot

  bus.on 'botStop', (id) ->
    existing = null
    if !(existing = _(bots).findWhere {id: id})
      return console.error err if err?

    existing.Stop (err) ->
      return console.error err if err?

      BotResource.Fetch id, (err, botRes) ->
        return console.error err if err?

        botRes.active = false
        botRes.Save (err) ->
          return console.error err if err?

          bots = _(bots).reject (bot) -> bot.id is id

