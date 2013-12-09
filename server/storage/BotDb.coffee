sql = require './connectors'
bots = sql.table 'bots'

class BotDb

  constructor: ->

  Fetch: (id, done) ->
    bots.Find id, done

  List: (done) ->
    bots.Select 'id', {}, {}, done

  Save: (blob, done) ->
    bots.Save blob, done

module.exports = new BotDb
