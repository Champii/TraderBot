sql = require './connectors'
trades = sql.table 'trades'

class TradeDb

  constructor: ->

  Fetch: (id, botId, done) ->
    trades.FindWhere '*', {id: id, bot_id: botId}, done

  List: (botId, done) ->
    trades.Select 'id', {bot_id: botId}, {limit: 10, sortBy: 'id', reverse: true}, done

  Save: (blob, done) ->
    trades.Save blob, done

module.exports = new TradeDb
