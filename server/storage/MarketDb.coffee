sql = require './connectors'
markets = sql.table 'markets'

class MarketDb

  constructor: ->

  Fetch: (id, done) ->
    markets.Find id, done

  List: (done) ->
    markets.Select 'id', {}, {}, done

  Save: (blob, done) ->
    markets.Save blob, done

module.exports = new MarketDb
