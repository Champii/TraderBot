_ = require 'underscore'
async = require 'async'
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
  volatility: null

  interval: null

  constructor: (@id, @pair) ->
    console.log 'constructor ticker', @pair, @id

    @lastTen = []
    @ema = 0
    @lastEma = 0
    @nbEma = 0
    @volatility = 0

    @ticker = new btce


  UpdateEma: (data, done) ->
    if @lastTen.length > 15
      @lastTen.shift()
    @lastTen.push data.ticker.last

    sma = 0
    if @nbEma < 15
      @nbEma++
      for value in @lastTen
        sma += value

      sma /= 15
      @lastEma = sma

    multi = 2 / 11

    @ema = (data.ticker.last - @lastEma) * multi + @lastEma

    @lastEma = @ema

    console.log 'Spread = ', (data.ticker.buy - data.ticker.sell).toFixed 3 if @pair is 'ltc_usd'
    done()

  UpdateVolatility: (trades, done) ->
    min = (_(trades).min (value) -> value.price).price
    max = (_(trades).max (value) -> value.price).price

    delta = (max - min) / min
    @volatility = delta * 100.0

    bid = 0
    ask = 0

    _(trades).each (value) ->
      bid++ if value.trade_type is 'bid'
      ask++ if value.trade_type is 'ask'

    console.log 'Bid = ', bid, 'Ask = ', ask if @pair is 'ltc_usd'

    done()

  Start: (done) ->

    if @interval?
      return done {}

    @interval = setInterval =>

      async.auto
        pairValue: (done) =>
          @ticker.ticker @pair, done

        trades: ['pairValue', (done) =>
          @ticker.trades @pair, done]

        updateVolatility: ['trades', (done, results) =>
          @UpdateVolatility results.trades, done]

        updateEma: ['trades', (done, results) =>
          @UpdateEma results.pairValue, done]

        savePairValue: ['updateEma', (done, results) =>
          MarketPairValuesResource.Add @id, results.pairValue.ticker.server_time, JSON.stringify(results.pairValue.ticker), done]

        tick: ['savePairValue', (done, results) =>
          if @nbEma >= 15
            bus.emit 'tickerBtce' + @pair, results.pairValue.ticker, @ema, @volatility
          done()]

      , (err, results) =>
        return console.error err if err?
        console.log 'Volatility of ', @pair, ' = ', @volatility.toFixed(2), '. Ema = ', @ema if @pair is 'ltc_usd'

    , 1000

    done()


  Stop: (done) ->
    if !(@interval?)
      return done {}

    clearInterval @interval
    @interval = null

    done()

module.exports = BtceTicker