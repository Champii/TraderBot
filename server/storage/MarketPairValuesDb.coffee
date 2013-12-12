sql = require './connectors'

market_pair_values = sql.table 'market_pair_values'

class MarketPairValuesDb

  constructor: ->

  Add: (data, done) ->
    market_pair_values.Insert data, done

  FetchAll: (done) ->
    market_pair_values.Select '*', {}, {}, (err, all) ->
      return done err if err?

      async.map all, JSON.parse, done


module.exports = new MarketPairValuesDb
