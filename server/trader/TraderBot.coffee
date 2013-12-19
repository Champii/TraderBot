fs = require 'fs'
btce = require 'btc-e'

bus = require '../bus'

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
    @opEma = 0

  StaticRangeAlgo: (data, ema) ->
    console.log data, ema

  Init: (done) ->
    @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
    if !@resource.simu
      @trade = new btce @resource.api.key, @resource.api.secret, =>
        @currentNonce++
        fs.writeFile("nonce.json", @currentNonce);
        return @currentNonce

    # console.log 'tickerBtce' + @resource.pair + 'TRIGGER'
    bus.on 'tickerBtce' + @resource.pair, (data, ema) =>
      if @opEma is 0
        @opEma = ema

      @MovingRangeAlgo data, ema if @resource.algo is 'movingRange'
      @StaticRangeAlgo data, ema if @resource.algo is 'staticRange'

    done()

  Run: (done) ->
    @Init (err) =>
      return done err if err?
      done()

  Stop: (done) ->
    done()

module.exports = TraderBot
