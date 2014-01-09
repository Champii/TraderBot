_ = require 'underscore'
async = require 'async'

bus = require '../bus'
log = require '../util/Log'

BotResource = require '../resources/BotResource'
TraderBot = require '../trader/TraderBot'

MarketResource = require '../resources/MarketResource'
PairResource = require '../resources/PairResource'

marketPairDb = require '../storage/MarketPairDb'

bots = []

exports.init = ->

  bus.on 'botStart', (id) ->
    if _(bots).findWhere {id: id}
      return


    async.auto
      bot: (done) ->
        BotResource.Fetch id, done

      market: ['bot', (done, results) ->
        MarketResource.FetchByName results.bot.market, done]

      pair: ['market', (done, results) ->
        PairResource.FetchByName results.bot.pair, done]

      marketPairId: ['pair', (done, results) ->
        marketPairDb.GetId results.market.id, results.pair.id, done]

    , (err, results) ->
      return log.Error err if err?

      log.Error 'START : ', results.bot

      newBot = new TraderBot results.bot.id, results.marketPairId.id
      log.Log 'Bot Start : ', results.bot.id
      newBot.Run (err) ->
        log.Log 'Bot Running : ', results.bot.id
        return log.Error err if err?
        results.bot.active = true
        results.bot.Save (err, bot) ->
          return log.Error err if err

          bots.push newBot

  bus.on 'botStop', (id) ->
    existing = null
    if !(existing = _(bots).findWhere {botId: id})
      return log.Error {'No bot to stop'}

    existing.Stop (err) ->
      return log.Error err if err?

      BotResource.Fetch id, (err, botRes) ->
        return log.Error err if err?

        botRes.active = false
        botRes.Save (err) ->
          return log.Error err if err?

          bots = _(bots).reject (bot) -> bot.id is id

