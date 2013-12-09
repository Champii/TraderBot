_ = require 'underscore'

BotResource = require '../resources/BotResource'

exports.mount = (app) ->
  app.get '/api/1/bots', (req, res) ->
    BotResource.List (err, bots) ->
      return res.locals.sendError err if err?

      res.send _(bots).invoke 'ToJSON'

  app.post '/api/1/bots', (req, res) ->
    BotResource.Deserialize req.body, (err, bot) ->
      return res.locals.sendError err if err?

      bot.Save (err, bot) ->
        return res.locals.sendError err if err?

        res.send 200, bot.ToJSON()
