_ = require 'underscore'

routes = [
  'html']
  # 'api']

exports.mount = (app) ->
  _(routes).each (route) ->
    require('./' + route + '_routes.coffee').mount(app);
