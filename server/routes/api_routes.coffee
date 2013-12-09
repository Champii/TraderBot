codes =
  'bad_request': 400
  'forbidden': 403
  'not_found': 404
  'conflict': 409
  'internal_error': 500

exports.mount = (app) ->
  app.all '/api/*', (req, res, next) ->
    res.locals.sendError = (err) ->
      code = codes[err.status] or 500
      body = null

      try
        body = err
      catch e
        body =
          status: 'internal_error'
          reason: err.message

      res.json code, body

    next()

