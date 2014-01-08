_ = require 'underscore'

OrderResource = require '../resources/OrderResource'

exports.mount = (app) ->
  app.get '/api/1/bots/:bot_id/orders', (req, res) ->
    OrderResource.List req.params.bot_id, (err, orders) ->
      return res.locals.sendError err if err?

      res.send _(orders).invoke 'ToJSON'
