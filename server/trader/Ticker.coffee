async = require 'async'

log = require '../util/Log'

Signals = require './signals/Signals'

class Ticker

  marketPairId: null
  market: null
  pair: null
  api: null
  interval: null
  signals: null

  constructor: (@marketPairId, @market, @pair) ->

    tickerName = ''
    if @market is 'btc-e'
      tickerName = 'Btce'
    else if @market is 'mt-gox'
      tickerName = 'MtGox'

    ticker = require './api/' + tickerName + 'Ticker'
    @api = new ticker @pair
    console.log ticker, './api/' + tickerName + 'Ticker', @market, @pair
    @signals = new Signals @marketPairId

  Simulate: (done) ->

    # for value in histo.USD.avg
    #   ticker = {ticker: {last: value[1], buy: value[1], sell: value[1]}}
    #   @UpdateMACD ticker, =>
    #     log.Log @lastValues
    #     if @lastValues.length >= maxEma
    #       bus.emit 'tickerBtce' + @pair, ticker.ticker, @macdHisto, @volatility


  Start: (done) ->

    if @interval?
      return done {}

    @interval = setInterval =>

      async.auto
        pairValue: (done) =>
          @api.Tick done

        trades: ['pairValue', (done) =>
          @api.Trades done]

        updateSignal: ['trades', (done, results) =>
          @signals.NewValue results.pairValue.ticker, results.trades
          done()]

        savePairValue: ['updateEma', (done, results) =>
          MarketPairValuesResource.Add @marketPairId, results.pairValue.ticker.server_time, JSON.stringify(results.pairValue.ticker), done]

        tick: ['savePairValue', (done, results) =>
          if @lastValues.length >= maxEma
            bus.emit 'ticker' + @marketPairId, results.pairValue.ticker
          done()]

      , (err, results) =>
        return log.Error err if err?

        log.Log 'Volatility of ', @pair, ' = ', @volatility.toFixed(2), '. Ema = ', @slowEma if @pair is 'ltc_usd'

    , 1000 * 60

    done()

  Stop: (done) ->
    if !(@interval?)
      return done {}

    clearInterval @interval
    @interval = null

    done()

module.exports = Ticker