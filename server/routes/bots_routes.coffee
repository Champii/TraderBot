_ = require 'underscore'

BotResource = require '../resources/BotResource'

exports.mount = (app) ->
  app.get '/api/1/bots', (req, res) ->
    BotResource.List (err, bots) ->
      return res.locals.sendError err if err?

      res.send
        bots: _(bots).invoke 'ToJSON'

