Settings = require 'settings'

config = new Settings require './config'
windowManager = require './WindowManager'

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

  ticker: null

  constructor: (@public, @trade, @ticker) ->
    @lastTen = []
    @trades = []
    @rangeStart = 0

  RangeAlgo: (data, balances) ->
    if ema <= opEma - config.range
      @Buy data, balances if !lastIsBuy
      opEma = ema
    else if ema >= opEma + config.range
      @Sell data, balances if lastIsBuy
      opEma = ema

  MaketAlgo: (data, balances)->

    diff = ema - opEma
    if diff > 0
      if lastIsBuy
        thresholdDown = 0.05
      else
        @Buy data, balances
      opEma = ema
    else if diff < 0
      gain = balances.funds.ltc * data.last - startUsd
      if lastIsBuy and gain >= 0
        @Sell data, balances
      else
        thresholdUp = 0.1
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

    if opEma is 0 and nbEma < 10
      opEma = ema

    windowManager.PrintError 'Debug : ' + ema.toFixed(2) + ' ' + opEma

    if nbEma >= 10
      @RangeAlgo data, balances if config.algo is 'range'
      @MarketAlgo data, balances if config.algo is 'market'


    gain = balances.funds.ltc * data.last + balances.funds.usd - startUsd

    windowManager.PrintGain {startUsd: startUsd, gain: gain}

    lastEma = ema

  LogTrade: (order, amount, price, curPrice) ->
    if @trades.length > 10
      @trades.shift()
    @trades.push
      order: order
      amount: amount.toFixed 2
      price: price.toFixed 2
      curPrice: curPrice.toFixed 2

    windowManager.PrintLastTrade @trades


  # Buy Ltc
  Buy: (currentPrice, balances) ->
    if config.simu
      ltc = balances.funds.usd / currentPrice.last
      @LogTrade 'Buy', ltc, balances.funds.usd, currentPrice.last
      balances.funds.ltc += ltc
      balances.funds.usd -= balances.funds.usd
      windowManager.PrintError 'Bougth : ' + ltc
      lastIsBuy = true
      # @first = currentPrice.last
    else
      amount = balances.funds.usd / currentPrice.last
      amount = (amount.toFixed 2) - 0.01
      @trade.trade 'ltc_usd', 'buy', currentPrice.last, amount, (err, data) =>
        if err
          return windowManager.PrintError err
        windowManager.PrintError 'Bought: ' + data.return.funds.ltc + 'ltc'
        lastIsBuy = true
        @ticker.emit 'updateUserInfo'

    windowManager.PrintUserInfo balances


  # Sell Ltc
  Sell: (currentPrice, balances) ->
    if config.simu
      usd = balances.funds.ltc * currentPrice.last
      @LogTrade 'Sell', balances.funds.ltc, usd, currentPrice.last
      balances.funds.ltc -= balances.funds.ltc
      balances.funds.usd += usd
      windowManager.PrintError 'Sold : ' + usd
      lastIsBuy = false
      # @first = currentPrice.last
    else
      windowManager.PrintError 'Price: ' + currentPrice.last + ' ' + balances.funds.ltc
      @trade.trade 'ltc_usd', 'sell', currentPrice.last, balances.funds.ltc, (err, data) =>
        if err
          return windowManager.PrintError err
        windowManager.PrintError 'Sold: ' + data.return.funds.usd + 'usd'
        lastIsBuy = false
        @ticker.emit 'updateUserInfo'

    windowManager.PrintUserInfo balances

module.exports = Trader
