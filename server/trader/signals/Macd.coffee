_ = require 'underscore'

log = require '../../util/Log'
bus = require '../../bus/Bus'

MarketPairValuesResource = require '../../resources/MarketPairValuesResource'

maxEma = 24

class Macd

  marketPairId: null
  lastValues: null

  fastEma: null
  slowEma: null
  signal: null
  lastSignals: null
  macdHisto: null

  constructor: (@marketPairId) ->

    @lastValues = []
    @volatility = 0

    @fastEma = 0
    @slowEma = 0
    @signal = 0

    @lastSignals = []

    @macdHisto = 0


    MarketPairValuesResource.ListLast @marketPairId, maxEma + 9, (err, values) =>
      return Log.Error err if err?

      _(values).each (value, key) => @NewValue value.value.last


  CalcSma: (nb, array) ->
    sma = 0
    if array.length < nb
      for value in array[..nb]
        sma += value

      sma /= nb

    return sma

  CalcEma: (nb, value, last) ->

    if @lastValues.length < nb
      last = @CalcSma nb, @lastValues

    multi = 2 / (nb + 1)

    ema = (value * multi) + (last * (1 - multi))

  CalcSignal: (nb, last) ->
    if @lastValues.length > maxEma
      if @lastSignals.length > nb
        @lastSignals.shift()
      @lastSignals.push @fastEma - @slowEma

      if @lastSignals.length < nb
        last = @CalcSma nb, @lastSignals

      multi = 2 / (nb + 1)

      ema = ((@fastEma - @slowEma) * multi) + (last * (1 - multi))


  NewValue: (value) ->
    if @lastValues.length > maxEma
      @lastValues.shift()
    @lastValues.push value

    @slowEma = @CalcEma 26, value, @slowEma
    @fastEma = @CalcEma 12, value, @fastEma
    @signal = @CalcSignal 9, @signal
    @macdHisto = (@fastEma - @slowEma) - @signal

    log.Error 'Macd : ', value, @slowEma, @fastEma, @signal, @macdHisto
    if (@lastSignals.lentgth > 9)
      bus.emit 'macd' + @marketPairId, @macdHisto

module.exports = Macd
