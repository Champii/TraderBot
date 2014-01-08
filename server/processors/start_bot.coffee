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

      market: (done) ->
        MarketResource.FetchByName bot.market, done

      pair: ['market', (done, results) ->
        PairResource.FetchByName bot.pair, done]

      marketPairId: ['pair', (done, results) ->
        marketPairDb.GetId results.market, results.pair, done]

    , (err, results) ->
      return log.Error err if err?

      log.Error 'START : ', bot

      newBot = new TraderBot results.bot.id, results.marketPairId.id
      log.Log 'Bot Start : ', results.bot.id
      newBot.Run (err) ->
        log.Log 'Bot Running : ', results.bot.id
        return log.Error err if err?
        bot.active = true
        bot.Save (err, bot) ->
          return log.Error err if err

          bots.push newBot

  bus.on 'botStop', (id) ->
    existing = null
    if !(existing = _(bots).findWhere {id: id})
      return log.Error err if err?

    existing.Stop (err) ->
      return log.Error err if err?

      BotResource.Fetch id, (err, botRes) ->
        return log.Error err if err?

        botRes.active = false
        botRes.Save (err) ->
          return log.Error err if err?

          bots = _(bots).reject (bot) -> bot.id is id

