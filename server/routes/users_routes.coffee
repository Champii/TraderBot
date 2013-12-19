_ = require 'underscore'
UserResource = require '../resources/UserResource'

exports.mount = (app) ->
  app.put '/api/1/user', (req, res) ->
    req.body.settings = JSON.stringify req.body.settings
    UserResource.Deserialize req.body, (err, user) ->
      return res.locals.sendError err if err?

      user.Save (err) ->
        return res.locals.sendError err if err?

        res.send 200

