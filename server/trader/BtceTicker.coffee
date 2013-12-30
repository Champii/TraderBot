_ = require 'underscore'
async = require 'async'
btce = require 'btc-e'

bus = require '../bus'

MarketPairValuesResource = require '../resources/MarketPairValuesResource'

histo = require '../../btcetrade.json'

maxEma = 26

class BtceTicker

  id: null
  ticker: null
  pair: null

  lastValues: null
  volatility: null

  # macd
  fastEma: null
  slowEma: null
  signal: null
  lastSignals: null
  macdHisto: null

  interval: null

  constructor: (@id, @pair) ->
    console.log 'constructor ticker', @pair, @id

    @lastValues = []
    @volatility = 0

    @fastEma = 0
    @slowEma = 0
    @signal = 0

    @lastSignals = []

    @macdHisto = 0

    @ticker = new btce

  CalcSma: (nb, array) ->
    sma = 0
    if array.length < nb
      for value in array[..nb]
        sma += value

      sma /= nb

    return sma

  CalcEma: (nb, data, last) ->

    if @lastValues.length < nb
      last = @CalcSma nb, @lastValues

    multi = 2 / (nb + 1)

    ema = (data.ticker.last * multi) + (last * (1 - multi))

  CalcSignal: (nb, last) ->
    if @lastValues.length > maxEma
      if @lastSignals.length > nb
        @lastSignals.shift()
      @lastSignals.push @fastEma - @slowEma

      if @lastSignals.length < nb
        last = @CalcSma nb, @lastSignals

      multi = 2 / (nb + 1)

      ema = ((@fastEma - @slowEma) * multi) + (last * (1 - multi))


  UpdateMACD: (data, done) ->
    if @lastValues.length > maxEma
      @lastValues.shift()
    @lastValues.push data.ticker.last

    @slowEma = @CalcEma 26, data, @slowEma
    @fastEma = @CalcEma 12, data, @fastEma
    @signal = @CalcSignal 9, @signal
    @macdHisto = (@fastEma - @slowEma) - @signal

    console.log 'fast =', @fastEma, 'slow =', @slowEma, 'signal =', @signal , 'macd =', @fastEma - @slowEma, 'macdHisto =', @macdHisto if @pair is 'ltc_usd'

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

  Simulate: (done) ->

    for value in histo.USD.avg
      ticker = {ticker: {last: value[1], buy: value[1], sell: value[1]}}
      @UpdateMACD ticker, =>
        console.log @lastValues
        if @lastValues.length >= maxEma
          bus.emit 'tickerBtce' + @pair, ticker.ticker, @macdHisto, @volatility

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
          @UpdateMACD results.pairValue, done]

        savePairValue: ['updateEma', (done, results) =>
          MarketPairValuesResource.Add @id, results.pairValue.ticker.server_time, JSON.stringify(results.pairValue.ticker), done]

        tick: ['savePairValue', (done, results) =>
          if @lastValues.length >= maxEma
            bus.emit 'tickerBtce' + @pair, results.pairValue.ticker, @macdHisto, @volatility
          done()]

      , (err, results) =>
        return console.error err if err?
        console.log 'Volatility of ', @pair, ' = ', @volatility.toFixed(2), '. Ema = ', @slowEma if @pair is 'ltc_usd'

    , 1000 * 60

    done()

  Stop: (done) ->
    if !(@interval?)
      return done {}

    clearInterval @interval
    @interval = null

    done()

module.exports = BtceTicker