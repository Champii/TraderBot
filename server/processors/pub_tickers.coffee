_ = require 'underscore'

bus = require '../bus'

MarketResource = require '../resources/MarketResource'
PairResource = require '../resources/PairResource'

marketPairDb = require '../storage/MarketPairDb'

BtceTicker = require '../trader/BtceTicker'

tickers = []

exports.init = ->
  bus.on 'startPubTickers', ->
    MarketResource.List (err, markets) ->
      return console.error err if err?

      _(markets).each (market) ->
        PairResource.ListByMarket market, (err, pairs) ->
          return console.error err if err?

          _(pairs).each (pair) ->
            marketPairDb.GetId market.id, pair.id, (err, id) ->
              return console.error err if err?

              if market.name is 'btc-e'
                tickers.push new BtceTicker id.id, pair.pair
