socket = require 'socket.io'

bus = require '../bus'

exports.init = (server) ->
  io = socket.listen server

  io.sockets.on 'connection', (socket)->
    hs = socket.handshake
    userId = hs.user_id

    socket.once 'disconnect', () ->

    bus.on 'newBot', (bot) ->
      socket.emit 'newBot', bot

    bus.on 'updateBot', (bot) ->
      socket.emit 'updateBot', bot
