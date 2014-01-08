_ = require 'underscore'

log = require '../util/Log'

BotResource = require '../resources/BotResource'

exports.mount = (app) ->
  app.get '/api/1/bots', (req, res) ->
    BotResource.ListByUser req.user.id, (err, bots) ->
      return res.locals.sendError err if err?

      res.send _(bots).invoke 'ToJSON'

  app.post '/api/1/bots', (req, res) ->
    BotResource.Deserialize req.body, (err, bot) ->
      return res.locals.sendError err if err?

      bot.Save (err, bot) ->
        return res.locals.sendError err if err?

        res.send 200, bot.ToJSON()

  app.put '/api/1/bots/:id', (req, res) ->
    BotResource.Fetch req.params.id, (err, bot) ->
      return res.locals.sendError err if err?

      _(req.body.algo_params).each (value, key) ->
        req.body.algo_params[key] = parseFloat(req.body.algo_params[key])

      _(req.body.balances).each (value, key) ->
        req.body.balances[key] = parseFloat(req.body.balances[key])

      log.Error 'Route save : ', bot, req.body

      _(bot).extend req.body

      bot.Save (err, bot) ->
        return res.locals.sendError err if err?

        res.send 200, bot.ToJSON()

  app.get '/api/1/bots/:id/start', (req, res) ->
    BotResource.Fetch req.params.id, (err, bot) ->
      return res.locals.sendError err if err?

      bot.Start()

      res.send 200


  app.get '/api/1/bots/:id/stop', (req, res) ->
    BotResource.Fetch req.params.id, (err, bot) ->
      return res.locals.sendError err if err?

      bot.Stop()

      res.send 200


