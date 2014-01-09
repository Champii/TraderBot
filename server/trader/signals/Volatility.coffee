_ = require 'underscore'

class Volatility

  volatility: null

  constructor: ->

  Update: (trades) ->
    min = (_(trades).min (value) -> value.price).price
    max = (_(trades).max (value) -> value.price).price

    delta = (max - min) / min
    @volatility = delta * 100.0

    # bid = 0
    # ask = 0

    # _(trades).each (value) ->
    #   bid++ if value.trade_type is 'bid'
    #   ask++ if value.trade_type is 'ask'

    # log.Log 'Bid = ', bid, 'Ask = ', ask if @pair is 'ltc_usd'

    return @volatility


module.exports = Volatility
