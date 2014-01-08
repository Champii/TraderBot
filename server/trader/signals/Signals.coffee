Macd = require './Macd'
Volatility = require './Volatility'

class Signals

  macd: null
  marketPairId: null
  volatility: null

  constructor: (@marketPairId) ->
    @macd = new Macd @marketPairId
    @volatility = new Volatility

  NewValue: (ticker, trades) ->
    # console.log ticker, trades
    @macd.NewValue ticker.last

module.exports = Signals
