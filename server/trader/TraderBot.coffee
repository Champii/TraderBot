btce = require 'btc-e'

bus = require '../bus'

# Trader = require './Trader'

class TraderBot

  id: null
  currentNonce: null
  resource: null

  lastTen: null
  ema: null
  lastEma: null
  gain: null

  constructor: (@resource) ->
    @id = @resource.id

    @lastTen = []
    @ema = 0
    @lastEma = 0
    @gain = 0
    @startUsd = 0

  Update: ->
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

  Init: (done) ->
    @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
    @trade = new BTCE config.api.key, config.api.secret, =>
      @currentNonce++
      fs.writeFile("nonce.json", @currentNonce);
      return @currentNonce

    bus.on 'tickerBtce' + @resource.pair, @Update

  Run: (done) ->
    @Init (err) =>
      return done err if err?
      done()

module.exports = TraderBot
