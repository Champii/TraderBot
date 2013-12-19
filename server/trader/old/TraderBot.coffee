fs = require 'fs'
BTCE = require 'btc-e'
Settings = require 'settings'

Ticker = require './Ticker'
config = new Settings require '../../settings/config'

printError = (err) ->
  console.error 'ERROR', err

class TraderBot

  id: null
  ticker: null
  trade: null
  currentNonce: null
  resource: null

  constructor: (@resource) ->
    @id = @resource.id

  Init: (done) ->
    @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
    @public = new BTCE
    @trade = new BTCE config.api.key, config.api.secret, =>
      @currentNonce++
      fs.writeFile("nonce.json", @currentNonce);
      return @currentNonce

    @ticker = new Ticker @public, @trade
    done()


  Run: (done) ->
    @Init (err) =>
      return done err if err?
      console.log 'Init Bot OK'
      @ticker.Run done

  Stop: (done) ->
    @ticker.Stop done

module.exports = TraderBot
