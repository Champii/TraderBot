_ = require 'underscore'
async = require 'async'
btce = require 'btc-e'

exports.mount = (app) ->

  app.get '/api/1/dashboard/balances', (req, res) ->

    async.auto
      tickerBtce: (done) ->
        keys = _(req.user.settings.keys).findWhere name: 'btce'
        ticker = new btce keys.key, keys.secret
        done null, ticker
      btceInfo: [(done, results) ->
        results.tickerBtce.getInfo done]
    , (err, results) ->
      return res.locals.sendError err if err?
      res.send 200, [{btce: results.btceInfo.funds}, {mtgox: {}}]

