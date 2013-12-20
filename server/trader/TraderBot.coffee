fs = require 'fs'
btce = require 'btc-e'

bus = require '../bus'

BotResource = require '../resources/BotResource'
TradeResource = require '../resources/TradeResource'
class TraderBot

  id: null
  currentNonce: null
  opEma: null
  lastIsBuy: false
  bot: null

  constructor: (@id) ->
    @opEma = 0

  StaticRangeAlgo: (data, ema) ->
    if ema > @bot.algo_params.max and @lastIsBuy
      @Sell data
    else if ema < @bot.algo_params.min and !@lastIsBuy
      @Buy data

  MovingRangeAlgo: (data, ema) ->
    if ema <= @opEma - @bot.algo_params.min
      @Sell data if @lastIsBuy
      @opEma = ema
    else if ema >= @opEma + @bot.algo_params.max
      @Buy data if !@lastIsBuy
      @opEma = ema

    if ema > @opEma and @lastIsBuy
      @opEma = ema

  Sell: (data) ->
    console.log 'Sell', data, @bot
    BotResource.Fetch @bot.id, (err, bot) =>
      return console.error err if err?

      @bot = bot

      pair = @bot.pair.split '_'
      if @bot.simu
        second = @bot.balances[pair[0]] * data.sell

        TradeResource.Deserialize {bot_id: @bot.id, order: 'sell', amount: @bot.balances[pair[0]].toFixed(2), rate: data.sell.toFixed(2)}, (err, trade) ->
          return console.error err if err?

          trade.Save (err) ->
            return console.error err if err?

        @bot.balances[pair[0]] = 0
        @bot.balances[pair[1]] += second
        @lastIsBuy = false

        @bot.Save (err) ->
          return console.error err if err?


      else
        1

  Buy: (data) ->
    console.log 'Buy', data, @bot
    BotResource.Fetch @bot.id, (err, bot) =>
      return console.error err if err?

      @bot = bot

      pair = @bot.pair.split '_'
      if @bot.simu
        first = @bot.balances[pair[1]] / data.buy

        TradeResource.Deserialize {bot_id: @bot.id, order: 'buy', amount: first.toFixed(2), rate: data.buy.toFixed(2)}, (err, trade) ->
          return console.error err if err?

          trade.Save (err) ->
            return console.error err if err?

        @bot.balances[pair[0]] += first
        @bot.balances[pair[1]] = 0
        @lastIsBuy = true

        @bot.Save (err) ->
          return console.error err if err?

      else
        1


  Init: (done) ->
    BotResource.Fetch @id, (err, bot) =>
      return done err if err?

      @bot = bot

      if !@bot.simu
        @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
        @trade = new btce @bot.api.key, @bot.api.secret, =>
          @currentNonce++
          fs.writeFile("nonce.json", @currentNonce);
          return @currentNonce

      # console.log 'tickerBtce' + @resource.pair + 'TRIGGER'
      bus.on 'tickerBtce' + @bot.pair, (data, ema) =>
        if @opEma is 0
          @opEma = ema

        console.log ema, @opEma
        @MovingRangeAlgo data, ema if @bot.algo is 'movingRange'
        @StaticRangeAlgo data, ema if @bot.algo is 'staticRange'

      done()

  Run: (done) ->
    @Init (err) =>
      return done err if err?
      done()

  Stop: (done) ->
    done()

module.exports = TraderBot
