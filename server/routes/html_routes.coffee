exports.mount = (app) ->

  # app.get '/(js|css|img|fonts)/*', (req, res) ->
  #   res.send 404

  app.get '*', (req, res) ->
    res.render 'app'


