_ = require 'underscore'

routes = [
  'api'
  'auth'
  'users'
  'dashboard'
  'bots'
  'trades'
  'markets'
  'pairs'
  'charts'
  'api_404'
  'html']

exports.mount = (app) ->
  _(routes).each (route) ->
    require('./' + route + '_routes.coffee').mount(app);
