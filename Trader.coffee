Settings = require 'settings'

config = new Settings require './config'
windowManager = require './WindowManager'

thresholdUp = 0.1
thresholdDown = 0.1
lastEma = 0
nbEma = 0
startUsd = 0
gain = 0
lastIsBuy = false

opEma = 0

class Trader

  lastTen: null
  trades: null

  constructor: ->
    @lastTen = []
    @trades = []

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

    lastEma = ema

    windowManager.PrintError 'Debug : ' + ema.toFixed(2) + ' ' + opEma

    if opEma is 0 and nbEma < 10
      opEma = ema

    if nbEma >= 10
      if ema - opEma > thresholdUp
        @Buy data, balances if !lastIsBuy
        opEma = ema
      else if ema - opEma < -thresholdDown
        gain = balances.funds.ltc * data.last - startUsd
        @Sell data, balances if lastIsBuy and gain > 0
        opEma = ema


      if !lastIsBuy
        gain = balances.funds.usd - startUsd
      else
        gain = balances.funds.ltc * data.last - startUsd

      windowManager.PrintGain {startUsd: startUsd, gain: gain}


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
      1


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
      1

    windowManager.PrintUserInfo balances

module.exports = Trader
