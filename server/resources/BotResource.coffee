async = require 'async'

botDb = require '../storage/BotDb'
bus = require '../bus'

class BotResource

  constructor: (blob) ->
    if blob?
      @id = blob.id if blob.id?
      @name = blob.name if blob.name?
      @desc = blob.desc if blob.desc?
      @market = blob.market || 'btce'
      @pair = blob.pair || 'pair'
      @algo = blob.algo || 'range'
      @simu = blob.simu || 'simu'
      @trades = blob.trades || []
      @orders = blob.orders || []
      @max_invest = blob.max_invest || 0
      @active = blob.active || false

  Save: (done) ->
    exists = @id?

    botDb.Save @Serialize(), (err, botId) =>
      return done err if err?

      if !exists
        @id = botId
        bus.emit 'newBot', @Serialize()

      done null, @

  Serialize: ->
    id: @id
    name: @name
    desc: @desc
    market: @market
    pair: @pair
    algo: @algo
    simu: @simu
    # trades: @trades
    # orders: @orders
    max_invest: @max_invest

  ToJSON: ->
    @Serialize()

  @Fetch: (id, done) ->
    botDb.Fetch id, (err, blob) =>
      console.log 'bot fetch ', err, blob
      return done err if err?

      BotResource.Deserialize blob, done

  @List: (done) =>
    botDb.List (err, ids) ->
      console.log 'bot list ', err, ids
      return done err if err?

      async.map ids, BotResource.Fetch, done

  @Deserialize: (blob, done) ->
    done null, new BotResource blob

module.exports = BotResource
