fs = require 'fs'
path = require 'path'

exports.init = ->
  basePath = __dirname

  fs.readdirSync(basePath).forEach (fileName) ->
    return 0 if fileName is 'index.coffee'

    filePath = path.join basePath, fileName
    fileStat = fs.statSync filePath

    require(filePath).init() if fileStat.isFile()
