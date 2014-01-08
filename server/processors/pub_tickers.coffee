_ = require 'underscore'
async = require 'async'

bus = require '../bus'
log = require '../util/Log'

MarketResource = require '../resources/MarketResource'
PairResource = require '../resources/PairResource'

marketPairDb = require '../storage/MarketPairDb'

# BtceTicker = require '../trader/BtceTicker'
Ticker = require '../trader/Ticker'

tickers = []

exports.init = ->
  bus.on 'startPubTickers', ->

    MarketResource.List (err, markets) ->
      return log.Error err if err?

      _(markets).each (market) ->
        PairResource.ListByMarket market, (err, pairs) ->
          return log.Error err if err?

          _(pairs).each (pair) ->
            marketPairDb.GetId market.id, pair.id, (err, id) ->
              return log.Error err if err?

              if market.name is 'btc-e' and pair.pair is 'ltc_usd'
                # ticker = new BtceTicker id.id, pair.pair
                ticker = new Ticker id.id, market.name, pair.pair
                # if pair.pair is 'ltc_usd'
                #   setTimeout =>
                #     ticker.Simulate ->
                #   , 20000
                # else
                ticker.Start ->
                tickers.push ticker
