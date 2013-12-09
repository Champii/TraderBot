exports.mount = (app) ->

  app.get '/api/*', (req, res) ->
    res.send 404, {error: 'no such method'}
