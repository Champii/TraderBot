fs = require 'fs'
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
  opEma: null

  constructor: (@resource) ->
    @id = @resource.id

    @lastTen = []
    @ema = 0
    @lastEma = 0
    @nbEma = 0
    @opEma = 0

  StaticRangeAlgo: (data) ->
    console.log data

  Update: (data) ->
    if @lastTen.length > 10
      @lastTen.shift()
    @lastTen.push data.last

    sma = 0
    if @nbEma < 10
      @nbEma++
      for value in @lastTen
        sma += value

      sma /= 10
      @lastEma = sma

    multi = 2 / 11

    @ema = (data.last - @lastEma) * multi + @lastEma

    if @opEma is 0 and @nbEma == 10
      @opEma = @ema

    # windowManager.PrintError 'Debug : ' + ema.toFixed(2) + ' ' + opEma

    if @nbEma >= 10
      @MovingRangeAlgo data if @resource.algo is 'movingRange'
      @StaticRangeAlgo data if @resource.algo is 'staticRange'



    # windowManager.PrintGain {startUsd: startUsd, gain: gain}

    @lastEma = @ema

  Init: (done) ->
    @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
    if !@resource.simu
      @trade = new btce @resource.api.key, @resource.api.secret, =>
        @currentNonce++
        fs.writeFile("nonce.json", @currentNonce);
        return @currentNonce

    # console.log 'tickerBtce' + @resource.pair + 'TRIGGER'
    bus.on 'tickerBtce' + @resource.pair, (data) =>
      @Update data

    done()

  Run: (done) ->
    @Init (err) =>
      return done err if err?
      done()

  Stop: (done) ->
    done()

module.exports = TraderBot
