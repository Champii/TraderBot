fs = require 'fs'
btce = require 'btc-e'
Settings = require 'settings'

config = new Settings require '../../settings/config'
bus = require '../bus'
log = require '../util/Log'

BotResource = require '../resources/BotResource'
TradeResource = require '../resources/TradeResource'

class TraderBot

  botId: null
  marketPairId: null
  currentNonce: null
  opEma: null
  lastIsBuy: false
  bot: null
  callback: null
  trade: null

  constructor: (@botId, @marketPairId) ->
    @opEma = 0


  StaticRangeAlgo: (data, ema) ->
    if ema > @bot.algo_params.max and @lastIsBuy
      @Sell data
    else if ema < @bot.algo_params.min and !@lastIsBuy
      @Buy data

  MACD: (data, macd) ->
    if macd > 0 and !@lastIsBuy
      @Buy data
    else if macd < 0 and @lastIsBuy
      @Sell data


  MovingRangeAlgo: (data, ema, volat) ->
    if ema <= @opEma - @bot.algo_params.min
      @Sell data if @lastIsBuy
      @opEma = ema
    else if ema >= @opEma + @bot.algo_params.max
      @Buy data if !@lastIsBuy
      @opEma = ema

    if ema > @opEma and @lastIsBuy
      @opEma = ema

  VMA: (data, ema) ->
    # Down
    if data.last < ema
      @Sell data if @lastIsBuy
    # Up
    if data.last > ema
      @Buy data if !@lastIsBuy

  Sell: (data) ->
    log.Log 'Sell', data, @bot
    BotResource.Fetch @bot.id, (err, bot) =>
      return log.Error err if err?

      @bot = bot

      pair = @bot.pair.split '_'
      second = @bot.balances[pair[0]] * data.sell

      if @bot.simu
        TradeResource.Deserialize {bot_id: @bot.id, order: 'sell', amount: @bot.balances[pair[0]].toFixed(2), rate: data.sell.toFixed(2)}, (err, trade) ->
          return log.Error err if err?

          trade.Save (err) ->
            return log.Error err if err?

        @bot.balances[pair[0]] = 0
        @bot.balances[pair[1]] += second
        @lastIsBuy = false

        @bot.Save (err) ->
          return log.Error err if err?

      else
        async.auto
          userInfo: (done) => @trade.getInfo done

          isOrder: ['userInfo', (done, results) =>
            if results.userInfo.open_orders
              return done 'Order in progress'
            return done null, {}]

          trade: ['isOrder', (done, results) =>
            @trade.trade @bot.pair, 'sell', data.sell, @bot.balances[pair[0]], done]

          saveOrder: ['trade', (done, results) =>
            OrderResource.Deserialize {bot_id: @bot.id, order: 'sell', amount: @bot.balances[pair[0]], rate: data.sell}, (err, order) =>
              return done err if err?

              order.save done]

        , (err, results) =>
          return log.Error if err?

          @bot.balances[pair[0]] = 0
          @bot.balances[pair[1]] += second
          @lastIsBuy = false

          @bot.Save (err) ->
            return log.Error err if err?

  Buy: (data) ->
    log.Log 'Buy', data, @bot
    BotResource.Fetch @bot.id, (err, bot) =>
      return log.Error err if err?

      @bot = bot

      pair = @bot.pair.split '_'
      first = @bot.balances[pair[1]] / data.buy

      if @bot.simu

        TradeResource.Deserialize {bot_id: @bot.id, order: 'buy', amount: first.toFixed(2), rate: data.buy.toFixed(2)}, (err, trade) ->
          return log.Error err if err?

          trade.Save (err) ->
            return log.Error err if err?

        @bot.balances[pair[0]] += first
        @bot.balances[pair[1]] = 0
        @lastIsBuy = true

        @bot.Save (err) ->
          return log.Error err if err?

      else
        async.auto
          userInfo: (done) => @trade.getInfo done

          isOrder: ['userInfo', (done, results) =>
            if results.userInfo.open_orders
              return done 'Order in progress'
            return done null, {}]

          trade: ['isOrder', (done, results) =>
            @trade.trade @bot.pair, 'buy', data.sell, @bot.balances[pair[0]], done]

          saveOrder: ['trade', (done, results) =>
            OrderResource.Deserialize {bot_id: @bot.id, order: 'buy', amount: @bot.balances[pair[0]], rate: data.sell}, (err, order) =>
              return done err if err?

              order.save done]

        , (err, results) =>
          return log.Errorif err?

          @bot.balances[pair[0]] += first
          @bot.balances[pair[1]] = 0
          @lastIsBuy = true

          @bot.Save (err) ->
            return log.Error err if err?


  Init: (done) ->
    BotResource.Fetch @botId, (err, bot) =>
      return done err if err?

      @bot = bot

      if !@bot.simu
        @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
        @trade = new btce @bot.api.key, @bot.api.secret, =>
          @currentNonce++
          fs.writeFile("nonce.json", @currentNonce);
          return @currentNonce

      # log.Log 'tickerBtce' + @resource.pair + 'TRIGGER'

      if @callback?
        return done {}

      @callback = (data, macd) =>
        # if @opEma is 0
        #   @opEma = ema

        @MACD data, macd #if @bot.algo is 'movingRange'
        # @MovingRangeAlgo data, ema, volat if @bot.algo is 'movingRange'
        # @VMA data, ema if @bot.algo is 'movingRange'
        # @StaticRangeAlgo data, ema, volat if @bot.algo is 'staticRange'

      bus.on 'macd' + @marketPairId, @callback

      done()

  Run: (done) ->
    @Init done

  Stop: (done) ->
    if !(@callback?)
      return done {}

    bus.removeListener 'tickerBtce' + @bot.pair, @callback
    done()

module.exports = TraderBot
