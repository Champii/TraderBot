express = require 'express'
path = require 'path'
Settings = require 'settings'

config = new Settings require '../../settings/config'

routes = require '../routes'
assets = require '../../settings/assets.json'

app = null

traderRoot = path.resolve __dirname, '../..'

exports.makeServer = () ->

  app = express()

  app.configure ->
    app.use express.static __dirname + '/public'
    app.set 'views', path.resolve traderRoot, 'public/views'
    # app.engine '.html', require('ejs').__express
    app.engine '.jade', require('jade').__express
    app.set 'view engine', 'jade'

  app.use require('connect-cachify').setup assets,
    root: path.join __dirname, 'public'
    production: config.minify

  app.use express.compress()

  routes.mount app

  app.listen 3000
