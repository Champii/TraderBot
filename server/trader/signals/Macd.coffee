_ = require 'underscore'

log = require '../../util/Log'

MarketPairValuesResource = require '../../resources/MarketPairValuesResource'

maxEma = 26

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


    MarketPairValuesResource.ListLast @marketPairId, maxEma * 2, (err, values) =>
      return Log.Error err if err?

      reversed = []
      _(values).each (value) => reversed.unshift value

      _(reversed).each (value) => @NewValue value.value.last


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
    if (@lastSignals.length > 9)
      return @macdHisto

    return null

module.exports = Macd
