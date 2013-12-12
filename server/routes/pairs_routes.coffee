_ = require 'underscore'

PairResource = require '../resources/PairResource'

exports.mount = (app) ->

  app.get '/api/1/markets/:market_id/pairs', (req, res) ->
    PairResource.ListByMarket req.market, (err, pairs) ->
      return res.locals.sendError err if err?

      res.send 200, _(pairs).invoke 'ToJSON'

  app.all '/api/1/markets/:market_id/pairs/:pair_id*', (req, res) ->
    PairResource.Fetch parseInt(req.params.pair_id, 10), (err, pair) ->
      return res.locals.sendError err if err?

      req.pair = pair
      next()

  app.all '/api/1/markets/:market_id/pairs/:pair_id', (req, res) ->
    res.send 200, req.pair.ToJSON()
