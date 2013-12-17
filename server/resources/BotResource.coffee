async = require 'async'
_ = require 'underscore'

botDb = require '../storage/BotDb'
bus = require '../bus'

class BotResource

  constructor: (blob) ->
    if blob?
      @id = blob.id if blob.id?
      @user_id = blob.user_id if blob.user_id?
      @name = blob.name if blob.name?
      @desc = blob.desc if blob.desc?
      @market = blob.market || 'btc-e'
      @pair = blob.pair || 'ltc_usd'
      @algo = blob.algo || 'range'
      @simu = blob.simu || true
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

      else
        bus.emit 'updateBot', @

      done null, @

  Serialize: ->
    id: @id
    user_id: @user_id
    name: @name
    desc: @desc
    market: @market
    pair: @pair
    algo: @algo
    simu: @simu
    # trades: @trades
    # orders: @orders
    max_invest: @max_invest
    active: @active

  ToJSON: ->
    @Serialize()

  Start: ->
    bus.emit 'botStart', @id

  Stop: ->
    bus.emit 'botStop', @id

  @StopAll: (done) ->
    done()
  #   BotResource.List (err, bots) ->
  #     return done err if err?

  #     async.map bots, (bot, done) ->
  #       if bot.active
  #         bot.active = false
  #         bot.Save done
  #       else
  #         done()
  #     , done

  @Fetch: (id, userId, done) ->
    botDb.Fetch id, userId, (err, blob) ->
      return done err if err?

      BotResource.Deserialize blob, done

  @List: (userId, done) ->
    botDb.List userId, (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), (id, done) ->
        BotResource.Fetch id, userId, done
      , done

  @Deserialize: (blob, done) ->
    done null, new BotResource blob

module.exports = BotResource
