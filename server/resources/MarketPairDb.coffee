sql = require './connectors'
market_pair = sql.table 'market_pair'

class MarketPairDb

  constructor: ->

  GetId: (marketId, pairId, done) ->
    market_pair.FindWhere 'id', {market_id: marketId, pair_id: pairId}, done

module.exports = new MarketPairDb
