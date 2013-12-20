_ = require 'underscore'

MarketResource = require '../resources/MarketResource'
PairResource = require '../resources/PairResource'

exports.mount = (app) ->
  app.get '/api/1/markets', (req, res) ->
    MarketResource.List (err, markets) ->
      return res.locals.sendError err if err?

      res.send 200, _(markets).invoke 'ToJSON'

  app.all '/api/1/markets/:market_id*', (req, res, next) ->
    MarketResource.Fetch parseInt(req.params.market_id, 10), (err, market) ->
      return res.locals.sendError err if err?

      req.market = market
      next()

  app.all '/api/1/markets/:market_id', (req, res) ->
    res.send 200, req.market.ToJSON()