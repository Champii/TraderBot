btce = require 'btc-e'

bus = require '../bus'

MarketPairValuesResource = require '../resources/MarketPairValuesResource'

class BtceTicker

  id: null
  ticker: null
  pair: null

  constructor: (@id, @pair) ->
    console.log 'constructor ticker', @pair, @id
    @ticker = new btce

    setInterval =>
      @ticker.ticker @pair, (err, data) =>
        return console.error err if err?


        MarketPairValuesResource.Add @id, data.ticker.server_time, JSON.stringify(data.ticker), (err) =>
          return console.error err if err?

          # console.log 'tickerBtce' + @pair
          bus.emit 'tickerBtce' + @pair, data

    , 1000


module.exports = BtceTicker