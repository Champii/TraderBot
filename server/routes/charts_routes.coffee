MarketPairValues = require '../resources/MarketPairValuesResource'
marketPairDb = require '../storage/MarketPairDb'

exports.mount = (app) ->
  app.get '/api/1/markets/:market_id/pairs/:pair_id/chart/:time', (req, res) ->
    marketPairDb.GetId req.params.market_id, req.params.pair_id, (err, id) ->
      return res.locals.sendError err if err?

      MarketPairValues.FetchAll id.id, parseInt(req.params.time, 10), (err, datas) ->
        return res.locals.sendError err if err?

        res.send 200, datas

