fs = require 'fs'
BTCE = require 'btc-e'
Settings = require 'settings'

Ticker = require './Ticker'
config = new Settings require '../../settings/config'

printError = (err) ->
  console.error 'ERROR', err

class TraderBot

  ticker: null
  public: null
  trade: null
  currentNonce: null

  constructor: ->
    @currentNonce = if fs.existsSync("nonce.json") then JSON.parse(fs.readFileSync("nonce.json")) else new Date().getTime()
    @public = new BTCE
    @trade = new BTCE config.api.key, config.api.secret, =>
      @currentNonce++
      fs.writeFile("nonce.json", @currentNonce);
      return @currentNonce

    @ticker = new Ticker @public, @trade

  Run: ->
    @ticker.Run()

module.exports = TraderBot
