Macd = require './Macd'
Volatility = require './Volatility'

log = require '../../util/Log'
bus = require '../../bus/Bus'

class Signals

  macd: null
  marketPairId: null
  volatility: null

  constructor: (@marketPairId) ->
    @macd = new Macd @marketPairId
    @volatility = new Volatility

  NewValue: (ticker, trades) ->
    # console.log ticker, trades
    macd = @macd.NewValue ticker.last
    volat = @volatility.Update trades

    log.Error 'Volat =', volat

    if volat > 0 && macd isnt null
      bus.emit 'macd' + @marketPairId, ticker, macd

module.exports = Signals
