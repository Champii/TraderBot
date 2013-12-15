marketPairValuesDb = require '../storage/MarketPairValuesDb'

class MarketPairValuesResource

  constructor: (blob) ->
    @values = blob

  @Add: (marketPairId, time, data, done) ->
    marketPairValuesDb.Add
      market_pair_id: marketPairId
      time: time
      value: data
    , done

  @FetchAll: (marketPairId, time, done) ->
    marketPairValuesDb.FetchAll marketPairId, time, done

module.exports = MarketPairValuesResource
