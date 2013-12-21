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
      @algo = blob.algo || 'staticRange'

      if !(blob.algo_params?)
        @algo_params = {min: 0, max: 0}
      else
        @algo_params = if _(blob.algo_params).isString() then JSON.parse blob.algo_params else blob.algo_params

      @simu = blob.simu || true
      @trades = blob.trades || []
      @orders = blob.orders || []
      @max_invest = blob.max_invest || 0
      @active = blob.active || false

      if !(blob.balances?)
        @balances = {ltc: 0, usd: 0}
      else
        @balances = if _(blob.balances).isString() then JSON.parse blob.balances else blob.balances


  DefaultBalances: ->
    balances = {}
    currencies = @pair.split '_'
    balances[currencies[0]] = 0
    balances[currencies[1]] = 0
    balances

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
    algo_params: JSON.stringify @algo_params
    simu: @simu
    max_invest: @max_invest
    active: @active
    balances: JSON.stringify @balances

  ToJSON: ->
    id: @id
    user_id: @user_id
    name: @name
    desc: @desc
    market: @market
    pair: @pair
    algo: @algo
    algo_params: @algo_params
    simu: @simu
    max_invest: @max_invest
    active: @active
    balances: @balances

  Start: ->
    bus.emit 'botStart', @id

  Stop: ->
    bus.emit 'botStop', @id

  @StopAll: (done) ->
    BotResource.List (err, bots) ->
      return done err if err?

      async.map bots, (bot, done) ->
        if bot.active
          bot.active = false
          bot.Save done
        else
          done()
      , done

  @Fetch: (id, done) ->
    botDb.Fetch id, (err, blob) ->
      return done err if err?

      BotResource.Deserialize blob, done

  @List: (done) ->
    botDb.List (err, ids) ->
      return done err if err?
      console.log err, ids

      async.map _(ids).pluck('id'), BotResource.Fetch, done

  @ListByUser: (userId, done) ->
    botDb.ListByUser userId, (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), BotResource.Fetch, done

  @Deserialize: (blob, done) ->
    console.log blob
    done null, new BotResource blob

module.exports = BotResource
