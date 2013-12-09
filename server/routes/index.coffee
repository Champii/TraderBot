_ = require 'underscore'

routes = [
  'api'
  'bots'
  'api_404'
  'html']
  # 'api']

exports.mount = (app) ->
  _(routes).each (route) ->
    require('./' + route + '_routes.coffee').mount(app);
