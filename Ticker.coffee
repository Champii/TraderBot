async = require 'async'
Settings = require 'settings'
EventEmitter = require('events').EventEmitter

config = new Settings require './config'
Trader = require './Trader'
windowManager = require './WindowManager'


printError = (err) ->
  windowManager.PrintError err

class Ticker extends EventEmitter

  public: null
  trade: null
  tickerInt: null
  trader: null
  balances: null

  constructor: (@public, @trade) ->
    @trader = new Trader @public, @trade, @

    @.on 'updateUserInfo', @GetUserInfo

  GetUserInfo: ->
    @trade.getInfo (err, data) =>
      return printError 'UserInfo: ' + err if err
      @balances = data
      # @balances =
      #   funds:
      #     usd: 500
      #     ltc: 0

      windowManager.PrintUserInfo data

  GetPairValue: (done) ->
    @public.ticker config.pair, (err, data) =>
      done()
      return printError 'PairValue: ' + err if err
      @trader.Update data.ticker, @balances
      windowManager.PrintPairValue data

  GetLastTrade: (done) ->
    params =
      from: 0
      count: 10
    @trade.tradeHistory params, (err, data) =>
      done()
      return printError 'TradeHistory: ' + err if err
      windowManager.PrintLastTrade data

  Run: ->
    @GetUserInfo()
    @tickerInt = setInterval =>
      async.series([
        (done) =>
          @GetPairValue done])
        # (done) =>
        #   @GetLastTrade done])
    , config.tick

  Stop: ->
    clearInterval @tickerInt

module.exports = Ticker
