passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

UserResource = require '../resources/UserResource'

passport.use new LocalStrategy (username, password, done) ->
  UserResource.FetchByLogin username, (err, user) ->
    return done err if err? and err.status isnt 'not_found'
    return done null, false, {message: 'Incorrect Username/password'} if err? or !(user?) or !user.ValidatePassword password
    return done null, user

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  UserResource.Fetch id, done

exports.mount = (app) ->
  app.get '/login', (req, res) ->
    res.render 'signin'

  app.post '/login', passport.authenticate('local'), (req, res) ->
    res.redirect '/'

  app.post '/logout', (req, res) ->
    req.logout()
    res.redirect '/'

  app.post '/signup', (req, res) ->
    UserResource.FetchByLogin req.body.username, (err, existing) ->
      if !(err?) and existing?
        return res.locals.sendError {status: 500, message: 'Existing User'}

      UserResource.Deserialize req.body, (err, user) ->
        return res.locals.sendError err if err?

        user.Save (err) ->
          return res.locals.sendError err if err?

          res.send 200




