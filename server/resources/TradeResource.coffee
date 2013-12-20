async = require 'async'
_ = require 'underscore'

tradeDb = require '../storage/TradeDb'
bus = require '../bus'

class TradeResource

  constructor: (blob) ->
    if blob?
      @id = blob.id if blob.id?
      @bot_id = blob.bot_id if blob.bot_id?
      @order = blob.order if blob.order?
      @amount = blob.amount if blob.amount?
      @rate = blob.rate if blob.rate?

  Save: (done) ->
    exists = @id?

    tradeDb.Save @Serialize(), (err, tradeId) =>
      return done err if err?

      if !exists
        @id = tradeId
        bus.emit 'newTrade', @Serialize()

    done null, @

  Serialize: ->
    id: @id
    bot_id: @bot_id
    order: @order
    amount: @amount
    rate: @rate

  ToJSON: ->
    @Serialize()

  @Fetch: (id, bot_id, done) ->
    tradeDb.Fetch id, bot_id, (err, blob) ->
      return done err if err?

      TradeResource.Deserialize blob, done

  @List: (bot_id, done) ->
    tradeDb.List bot_id, (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), (id, done) ->
        TradeResource.Fetch id, bot_id, done
      , done

  @Deserialize: (blob, done) ->
    done null, new TradeResource blob

module.exports = TradeResource

