_ = require 'underscore'

routes = [
  'api'
  'auth'
  'bots'
  'markets'
  'pairs'
  'charts'
  'api_404'
  'html']

exports.mount = (app) ->
  _(routes).each (route) ->
    require('./' + route + '_routes.coffee').mount(app);
