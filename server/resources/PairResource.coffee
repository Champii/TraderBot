_ = require 'underscore'
async = require 'async'

pairDb = require '../storage/PairDb'

class PairResource

  constructor: (blob) ->
    @id = blob.id if blob.id?
    @pair = blob.pair if blob.pair?

  Serialize: ->
    id: @id
    pair: @pair

  ToJSON: ->
    @Serialize()

  @Fetch: (id, done) ->
    pairDb.Fetch id, (err, blob) =>
      return done err if err?

      PairResource.Deserialize blob, done

  @ListByMarket: (market, done) ->
    pairDb.ListByMarketId market.id, (err, pairIds) ->
      return done err if err?

      async.map _(pairIds).pluck('pair_id'), PairResource.Fetch, done

  @List: (done) ->
    pairDb.List (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), PairResource.Fetch, done

  @Deserialize: (blob, done) ->
    done null, new PairResource blob

module.exports = PairResource
