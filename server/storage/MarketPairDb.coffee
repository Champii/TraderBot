sql = require './connectors'
market_pairs = sql.table 'market_pairs'

class MarketPairDb

  constructor: ->

  GetId: (marketId, pairId, done) ->
    market_pairs.FindWhere 'id', {market_id: marketId, pair_id: pairId}, done

module.exports = new MarketPairDb
