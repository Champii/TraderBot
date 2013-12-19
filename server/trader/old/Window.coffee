nc = require 'ncurses'
Settings = require 'settings'

config = new Settings require '../../settings/config'

minWinH = config.minWinH
maxWinH = config.maxWinH

class Window
  h: null
  w: null
  x: null
  y: null
  name: null
  strs: null
  ncWin: null

  constructor: (@name, @h, @w, @x, @y) ->
    @strs = []
    @ncWin = new nc.Window @h, @w, @x, @y
    @ncWin.frame @name

  AddRow: (str) ->
    if @h > maxWinH
      @strs.shift()
    else
      @h++
    @strs.push str
    @ncWin.resize @h, @w
    @Erase()
    @Draw()

  Draw: ->
    for line, i in @strs
      @ncWin.addstr i + 1, 1, line

    @ncWin.frame @name
    @Refresh()

  Erase: ->
    @ncWin.erase()

  Clear: ->
    @h = minWinH
    @Erase()
    @ncWin.frame @name
    @strs = []

  Refresh: ->
    @ncWin.refresh()


module.exports = Window
