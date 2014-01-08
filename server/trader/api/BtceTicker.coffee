btce = require 'btc-e'

class BtceTicker

  pair: null
  ticker: null

  constructor: (@pair) ->
    @ticker = new btce

  Tick: (done) ->
    @ticker.ticker @pair, done

  Trades: (done) ->
    @ticker.trades @pair, done

module.exports = BtceTicker
