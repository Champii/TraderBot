async = require 'async'
Settings = require 'settings'

config = new Settings require './config'
Trader = require './Trader'
windowManager = require './WindowManager'
bus = require './Bus'


printError = (err) ->
  windowManager.PrintError err

class Ticker

  public: null
  trade: null
  tickerInt: null
  trader: null
  balances: null
  queue: null

  constructor: (@public, @trade) ->
    @trader = new Trader @public, @trade
    @queue = []

    bus.on 'updateUserInfo', (done) =>
      @queue.push =>
        @GetUserInfo done
    bus.on 'updateLastTrade', =>
      @queue.push =>
        @GetLastTrade ->
    bus.on 'updateActiveOrder', (done) =>
      @queue.push =>
        @GetOrders done

    bus.on 'cancelOrder', (id, order) =>
      @CancelOrder id

    if config.simu
      @balances =
        funds:
          usd: 500
          ltc: 0


  GetUserInfo: (done) ->
    @trade.getInfo (err, data) =>
      printError 'UserInfo: ' + err if err
      return done err if err and done?
      return if err and !(done?)

      if !config.simu
        @balances = data
      done null, data if done?

      windowManager.PrintUserInfo @balances

  GetPairValue: (done) ->
    @public.ticker config.pair, (err, data) =>
      done() if done?
      return printError 'PairValue: ' + err if err
      @trader.Update data.ticker, @balances
      windowManager.PrintPairValue data

  GetLastTrade: (done) ->
    params =
      # from: 0
      count: 9
    @trade.tradeHistory params, (err, data) =>
      done() if done?
      return printError 'TradeHistory: ' + err if err
      windowManager.PrintLastTrade data

  GetOrders: (done) ->
    # windowManager.PrintError 'Entering getOrder'
    @trade.activeOrders 'ltc_usd', (err, data) =>
      # windowManager.PrintError 'getOrders answers !'
      for k, i of data
        if i.timestamp_created < (new Date().getTime() / 1000 + 5)
          bus.emit 'cancelOrder', k, i
        windowManager.PrintError k + ' ' + i.amount + ' ' + i.timestamp_created + ' ' + (new Date().getTime() / 1000 + 5)

      windowManager.PrintActiveOrders data
        # @queue.push =>
        #   @GetOrder done
      # printError 'Orders: ' + err if err
      done err, data if done?

  CancelOrder: (id, done) ->
    @trade.cancelOrder id, (err, data) =>
      windowManager.PrintError 'Canceled order ' + id


  Run: ->
    async.auto
      getUserInfo: (done) =>
        @GetUserInfo done
      getLastTrade: ['getUserInfo', (done) =>
        @GetLastTrade done]
      getOrders: ['getLastTrade', (done) =>
        @GetOrders done]


    @tickerInt = setInterval =>
      action = @queue.pop()
      action() if action?
    , config.tick / 2

    setInterval =>
      @queue.push =>
        @GetPairValue =>
    , config.tick

    setInterval =>
      @queue.push =>
        @GetUserInfo()
      @queue.push =>
        @GetOrders()
    , config.tick * 2

  Stop: ->
    clearInterval @tickerInt

module.exports = Ticker
