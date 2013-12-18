_ = require 'underscore'

TradeResource = require '../resources/TradeResource'

exports.mount = (app) ->
  app.get '/api/1/bots/:bot_id/trades', (req, res) ->
    TradeResource.List req.params.bot_id, (err, trades) ->
      return res.locals.sendError err if err?

      res.send _(trades).invoke 'ToJSON'