btce = require 'btc-e'

MarketPairValuesResource = require '../resources/MarketPairValuesResource'

class BtceTicker

  ticker: null
  pair: null
  id: null

  constructor: (@id, @pair) ->
    console.log 'constructor ticker', @pair, @id
    @ticker = new btce

    setInterval =>
      @ticker.ticker @pair, (err, data) =>
        return console.error err if err?

        MarketPairValuesResource.Add {market_pair_id: id, value: JSON.stringify(data)}, (err) ->
          return console.error err if err?

    , 1000


module.exports = BtceTicker