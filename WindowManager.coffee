nc = require 'ncurses'
Settings = require 'settings'

config = new Settings require './config'
Window = require './Window'

errorNb = 0

minWinH = config.minWinH
maxWinH = config.maxWinH

class WindowManager

  wins: null
  lastPairValue: null

  constructor: ->
    @wins = {}
    @AddWindow 'TraderBot'
    nc.showCursor = false

    @AddWindow 'Balances', minWinH, 18, 1, 1
    @AddWindow 'Status', minWinH, 91, 1, nc.cols - 92
    @AddWindow 'LastPairValue', minWinH, 30, nc.lines - maxWinH, 1
    @AddWindow 'CurrentPairValue', minWinH, 30, nc.lines - maxWinH, 31
    @AddWindow 'LastTrade', minWinH, 50, nc.lines - maxWinH, 61
    @AddWindow 'Gains', minWinH, 30, Math.floor(nc.lines / 3), 1
    @AddWindow 'ActiveOrders', minWinH, 50, nc.lines - (maxWinH * 2), 61

    @wins['TraderBot'].Refresh()

  AddWindow: (name, h, w, x, y) ->
    @wins[name] = new Window name, h, w, x, y

  PrintUserInfo: (infos) ->
    @wins['Balances'].Clear()
    for currency, value of infos.funds
      if value
        @wins['Balances'].AddRow currency + ': ' + value

  PrintPairValue: (infos) ->

    @wins['LastPairValue'].Clear()
    for value in @wins['CurrentPairValue'].strs
      @wins['LastPairValue'].AddRow value

    @wins['CurrentPairValue'].Clear()
    for key, value of infos.ticker
      @wins['CurrentPairValue'].AddRow key + ': ' + value

  PrintLastTrade: (infos) ->
    @wins['LastTrade'].Clear()
    for key, value of infos
      str = key + ': ' + value.type + ' : ' + value.amount + 'ltc for ' + value.rate + 'usd'
      str += ' (' + value.price + ')' if value.price?
      @wins['LastTrade'].AddRow str
    # @wins['LastTrade'].Clear()
    # for value in infos
    #   @wins['LastTrade'].AddRow value.order + ': ' + value.amount + 'ltc for ' + value.price + 'usd (1ltc = ' + value.curPrice + 'usd)'

  PrintActiveOrders: (infos) ->
    @wins['ActiveOrders'].Clear()
    for key, value of infos
      @wins['ActiveOrders'].AddRow key + ': ' + value.type + ': ' + value.amount + 'ltc for ' + value.rate + 'usd'

  PrintGain: (infos) ->
    @wins['Gains'].Clear()
    @wins['Gains'].AddRow 'Start USD : ' + infos.startUsd
    @wins['Gains'].AddRow 'Gains USD : ' + infos.gain


  PrintError: (err) ->
    @wins['Status'].AddRow errorNb++ + ': ' + err

module.exports = new WindowManager
