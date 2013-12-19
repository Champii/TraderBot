btce = require 'btc-e'

bus = require '../bus'

MarketPairValuesResource = require '../resources/MarketPairValuesResource'

class BtceTicker

  id: null
  ticker: null
  pair: null

  lastTen: null
  ema: null
  lastEma: null
  gain: null
  opEma: null

  constructor: (@id, @pair) ->
    console.log 'constructor ticker', @pair, @id

    @lastTen = []
    @ema = 0
    @lastEma = 0
    @nbEma = 0

    @ticker = new btce

    setInterval =>
      @ticker.ticker @pair, (err, data) =>
        return console.error err if err?

        if @lastTen.length > 10
          @lastTen.shift()
        @lastTen.push data.ticker.last

        sma = 0
        if @nbEma < 10
          @nbEma++
          for value in @lastTen
            sma += value

          sma /= 10
          @lastEma = sma

        multi = 2 / 11

        @ema = (data.ticker.last - @lastEma) * multi + @lastEma

        @lastEma = @ema

        MarketPairValuesResource.Add @id, data.ticker.server_time, JSON.stringify(data.ticker), (err) =>
          return console.error err if err?

          if @nbEma >= 10
            bus.emit 'tickerBtce' + @pair, data.ticker, @ema

    , 1000


module.exports = BtceTicker