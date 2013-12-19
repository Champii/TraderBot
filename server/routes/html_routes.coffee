exports.mount = (app) ->

  # app.get '/(js|css|img|fonts)/*', (req, res) ->
  #   res.send 404

  app.get '*', (req, res) ->
    if !(req.user?)
      return res.redirect '/login'
      # return res.render 'signin'

    res.render 'app',
      user: req.user.ToJSON()
