sql = require './connectors'
bots = sql.table 'bots'

class BotDb

  constructor: ->

  Fetch: (id, done) ->
    bots.FindWhere '*', {id: id}, done

  List: (done) ->
    bots.Select 'id', {}, {}, done

  ListByUser: (userId, done) ->
    bots.Select 'id', {user_id: userId}, {}, done

  Save: (blob, done) ->
    bots.Save blob, done

module.exports = new BotDb
