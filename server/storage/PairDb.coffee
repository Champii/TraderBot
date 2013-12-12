sql = require './connectors'
pairs = sql.table 'pairs'
market_pairs = sql.table 'market_pairs'

class PairDb

  constructor: ->

  Fetch: (id, done) ->
    pairs.Find id, done

  List: (done) ->
    pairs.Select 'id', {}, {}, done

  ListByMarketId: (marketId, done) ->
    market_pairs.Select 'pair_id', {market_id: marketId}, {}, done

  Save: (blob, done) ->
    pairs.Save blob, done

module.exports = new PairDb
