sql = require './connectors'
users = sql.table 'users'

class UserDb

  constructor: ->

  Fetch: (id, done) ->
    users.Find id, done

  FetchByLogin: (login, done) ->
    users.FindWhere '*', {login: login}, done

  List: (done) ->
    users.Select 'id', {}, {}, done

  Save: (blob, done) ->
    users.Save blob, done

module.exports = new UserDb
