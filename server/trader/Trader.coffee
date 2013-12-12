async = require 'async'
Settings = require 'settings'

config = new Settings require '../../settings/config'
# windowManager = require './WindowManager'
bus = require '../bus'


thresholdUp = 0.1
thresholdDown = 0.1
ema = 0
lastEma = 0
nbEma = 0
startUsd = 0
gain = 0
lastIsBuy = false
opEma = 0

class Trader

  public: null
  trade: null

  lastTen: null
  trades: null

  rangeStart:null

  constructor: (@public, @trade) ->
    @lastTen = []
    @trades = []
    @rangeStart = 0

    bus.on 'cancelOrder', (id, order) =>
      if order.type is 'sell'
        lastIsBuy = true
      else
        lastIsBuy = false
      # windowManager.PrintError 'Current state : ' + lastIsBuy

  StaticRangeAlgo: (data, balances) ->
    if ema < config.range.down
      @Buy data, balances if !lastIsBuy
    else if ema > config.range.up
      @Sell data, balances if lastIsBuy

  MovingRangeAlgo: (data, balances) ->
    if ema <= opEma - config.range.down
      @Sell data, balances if lastIsBuy
      opEma = ema
    else if ema >= opEma + config.range.up
      @Buy data, balances if !lastIsBuy
      opEma = ema

    if ema > opEma and lastIsBuy
      opEma = ema

  Update: (data, balances) ->
    if @lastTen.length > 10
      @lastTen.shift()
    @lastTen.push data.last

    sma = 0
    if nbEma < 10
      nbEma++
      startUsd = balances.funds.usd + balances.funds.ltc * data.last
      for value in @lastTen
        sma += value

      sma /= 10
      lastEma = sma

    multi = 2 / 11

    ema = (data.last - lastEma) * multi + lastEma

    if opEma is 0 and nbEma == 10
      opEma = ema

    # windowManager.PrintError 'Debug : ' + ema.toFixed(2) + ' ' + opEma

    if nbEma >= 10
      @MovingRangeAlgo data, balances if config.algo is 'MovingRange'
      @StaticRangeAlgo data, balances if config.algo is 'StaticRange'


    gain = balances.funds.ltc * data.last + balances.funds.usd - startUsd

    # windowManager.PrintGain {startUsd: startUsd, gain: gain}

    lastEma = ema

  LogTrade: (type, amount, price, rate) ->
    if @trades.length > 10
      @trades.shift()

    @trades.push
      type: '' + type
      amount: amount.toFixed 2
      rate: rate.toFixed 2
      price: price.toFixed 2

    # windowManager.PrintLastTrade @trades


  # Buy Ltc
  Buy: (currentPrice, balances) ->
    if config.simu
      ltc = balances.funds.usd / currentPrice.buy
      @LogTrade 'Buy', ltc, balances.funds.usd, currentPrice.buy
      balances.funds.ltc += ltc
      balances.funds.usd -= balances.funds.usd
      # windowManager.PrintError 'Bougth : ' + ltc
      lastIsBuy = true
      # @first = currentPrice.last
      # windowManager.PrintUserInfo balances
    else
      async.auto
        userInfos: (done) =>
          bus.emit 'updateUserInfo', done

        trade: ['userInfos', (done, results) =>
          if !results.userInfos.open_orders
            amount = results.userInfos.funds.usd / currentPrice.buy
            amount = (amount.toFixed 2) - 0.01
            # windowManager.PrintError 'Price Buy: ' + currentPrice.buy + ' ' + amount

            @trade.trade 'ltc_usd', 'buy', currentPrice.buy, amount, done
          else
            done 'Existing order : exit'

        ]
      , (err, results) =>
        if err
          # @ticker.emit 'updateActiveOrder'
          return #windowManager.PrintError err

        # windowManager.PrintError 'Bought: ' + results.trade.funds.ltc + 'ltc'
        lastIsBuy = false
        # @ticker.emit 'updateActiveOrder'
        # @ticker.emit 'updateUserInfo'
        bus.emit 'updateLastTrade'


  # Sell Ltc
  Sell: (currentPrice, balances) ->
    if config.simu
      usd = balances.funds.ltc * currentPrice.sell
      @LogTrade 'Sell', balances.funds.ltc, usd, currentPrice.sell
      balances.funds.ltc -= balances.funds.ltc
      balances.funds.usd += usd
      # windowManager.PrintError 'Sold : ' + usd
      lastIsBuy = false
      # windowManager.PrintUserInfo balances
      # @first = currentPrice.last
    else
      async.auto
        userInfos: (done) =>
          bus.emit 'updateUserInfo', done

        trade: ['userInfos', (done, results) =>
          if !results.userInfos.open_orders
            amount = (results.userInfos.funds.ltc.toFixed 2) - 0.01
            # windowManager.PrintError 'Price Sell: ' + currentPrice.sell + ' ' + amount

            @trade.trade 'ltc_usd', 'sell', currentPrice.sell, amount, done
          else
            done 'Existing order : exit'
        ]
      , (err, results) =>
        if err
          # @ticker.emit 'updateActiveOrder'
          return #windowManager.PrintError err

        # windowManager.PrintError 'Sold: ' + results.trade.funds.usd + 'usd'
        lastIsBuy = false
        # @ticker.emit 'updateActiveOrder'
        # @ticker.emit 'updateUserInfo'
        bus.emit 'updateLastTrade'


module.exports = Trader
