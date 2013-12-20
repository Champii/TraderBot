async = require 'async'

sql = require './connectors'


market_pair_values = sql.table 'market_pair_values'

class MarketPairValuesDb

  constructor: ->

  Add: (data, done) ->
    market_pair_values.Insert data, done

  FetchAll: (marketPairId, time, done) ->
    where = {}
    if time?
      where =
        time:
          sup: true
          val: time

    where.market_pair_id = marketPairId
    market_pair_values.Select '*', where, {orderBy: 'time'}, (err, all) ->
      return done err if err?

      async.map all, (data, done) ->
        data.value = JSON.parse data.value
        done null, data
      , done


module.exports = new MarketPairValuesDb
