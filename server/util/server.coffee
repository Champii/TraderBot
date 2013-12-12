express = require 'express'
path = require 'path'
Settings = require 'settings'
exec = require('child_process').exec
http = require 'http'
coffeeMiddleware = require 'coffee-middleware'

config = new Settings require '../../settings/config'
routes = require '../routes'
assets = require '../../settings/assets.json'
sockets = require '../socket/socket'
processors = require '../processors'
bus = require '../bus'

app = null

traderRoot = path.resolve __dirname, '../..'

exports.makeServer = () ->

  app = express()

  app.use coffeeMiddleware
      src: path.resolve traderRoot, 'public'
      # compress: true
      prefix: 'js'
      bare: true
      force: true

  app.configure ->

    app.use require('connect-cachify').setup assets,
      root: path.join traderRoot, 'public'
      production: config.minify

    # app.use require('connect-assets')(path.resolve traderRoot, 'public/js')
    app.use express.static path.resolve traderRoot, '/public'
    app.set 'views', path.resolve traderRoot, 'public/views'
    # app.engine '.html', require('ejs').__express
    app.engine '.jade', require('jade').__express
    app.set 'view engine', 'jade'


  app.use(express.static(path.resolve(traderRoot, 'public')));

  app.use express.bodyParser()

  app.use app.router

  # app.use express.compress()

  routes.mount app

  processors.init()

  bus.emit 'tbInit'

  server = http.createServer app

  server.listen 3000

  sockets.init server
