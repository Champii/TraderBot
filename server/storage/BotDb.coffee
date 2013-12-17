sql = require './connectors'
bots = sql.table 'bots'

class BotDb

  constructor: ->

  Fetch: (id, userId, done) ->
    bots.FindWhere '*', {id: id, user_id: userId}, done

  List: (userId, done) ->
    bots.Select 'id', {user_id: userId}, {}, done

  Save: (blob, done) ->
    bots.Save blob, done

module.exports = new BotDb
