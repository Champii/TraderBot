mysql = require './Mysql'

class Table

  name: null

  constructor: (@name) ->

  Find: (id, done) ->
    @FindWhere '*', id, done

  FindWhere: (fields, where, done) ->
    @Select fields, where, {limit: 1}, (err, results) ->
      return done err if err?

      if results.length is 0
        return done
          status: 'not_found'
          reason: JSON.stringify where
          source: @name

      done null, results[0]

  Select: (fields, where, options, done) ->
    mysql.Select @name, fields, where, options, done

  Save: (blob, done) ->
    if blob.id?
      @Update blob, {id: blob.id}, done
    else
      @Insert blob, done

  Insert: (blob, done) ->
    mysql.Insert @name, blob, done

  Update: (blob, where, done) ->
    mysql.Update @name, blob, where, done

module.exports.table = (name) ->
  return new Table name
