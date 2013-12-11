exports.mount = (app) ->
  app.get '/api/1/availableMarket', (req, res) ->
    res.send 200, ['btc-e', 'mt-gox']

  app.get '/api/1/availablePair', (req, res) ->
    res.send 200, ['btc_usd', 'ltc_usd']

