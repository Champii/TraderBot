marketPairValuesDb = require '../storage/MarketPairValuesDb'

class MarketPairValuesResource

  constructor: (blob) ->
    @values = blob

  @Add: (data, done) ->
    marketPairValuesDb.Add data, done

  @FetchAll: (done) ->
    marketPairValuesDb.FetchAll done

module.exports = MarketPairValuesResource
