async = require 'async'
_ = require 'underscore'

orderDb = require '../storage/OrderDb'
bus = require '../bus'

class OrderResource

  constructor: (blob) ->
    if blob?
      @id = blob.id if blob.id?
      @bot_id = blob.bot_id if blob.bot_id?
      @order = blob.order if blob.order?
      @amount = blob.amount if blob.amount?
      @rate = blob.rate if blob.rate?

  Save: (done) ->
    exists = @id?

    orderDb.Save @Serialize(), (err, tradeId) =>
      return done err if err?

      if !exists
        @id = tradeId
        bus.emit 'newOrder', @Serialize()

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
    orderDb.Fetch id, bot_id, (err, blob) ->
      return done err if err?

      OrderResource.Deserialize blob, done

  @List: (bot_id, done) ->
    orderDb.List bot_id, (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), (id, done) ->
        OrderResource.Fetch id, bot_id, done
      , done

  @Deserialize: (blob, done) ->
    done null, new OrderResource blob

module.exports = OrderResource

