sql = require './connectors'
orders = sql.table 'orders'

class OrderDb

  constructor: ->

  Fetch: (id, botId, done) ->
    orders.FindWhere '*', {id: id, bot_id: botId}, done

  List: (botId, done) ->
    orders.Select 'id', {bot_id: botId}, {limit: 10, sortBy: 'id', reverse: true}, done

  Save: (blob, done) ->
    orders.Save blob, done

module.exports = new OrderDb
