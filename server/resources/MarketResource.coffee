_ = require 'underscore'
async = require 'async'

PairResource = require './PairResource'

marketDb = require '../storage/MarketDb'

class MarketResource

  constructor: (blob) ->
    @id = blob.id if blob.id?
    @name = blob.name if blob.name?

  ListPairs: (done) ->
    PairResource.FetchByMarketId @id, done

  Serialize: ->
    id: @id
    name: @name

  ToJSON: ->
    @Serialize()

  @Fetch: (id, done) ->
    marketDb.Fetch id, (err, blob) =>
      return done err if err?

      MarketResource.Deserialize blob, done

  @FetchByName: (name, done) ->
    marketDb.FetchByName name, (err, blob) =>
      return done err if err?

      MarketResource.Deserialize blob, done

  @List: (done) ->
    marketDb.List (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), MarketResource.Fetch, done


  @Deserialize: (blob, done) ->
    done null, new MarketResource blob

module.exports = MarketResource