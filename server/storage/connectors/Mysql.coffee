_ = require 'underscore'
mysql = require 'mysql'

class Mysql

  constructor: ->

  Select: (table, fields, where, options, done) ->
    f = fields
    if Array.isArray fields
      f = fields.join(',')

    query = 'select ' + f + ' from ' + table
    hasConditions = _(where).size() > 0

    if (hasConditions)
      query += ' where ' + _(where).map(@_MakeSQLCondition).join(' and ');

    mysql.query query, where, (err, rows) ->
      return done err if err?

      done null, rows

  Insert: (table, fields, done) ->
    query = 'insert into ' + table + ' set ?'

    mysql.query query, fields, (err, results) ->
      return done err if err?

      done null, results.insertId

  Update: (table, fields, where, done) ->
    query = 'update ' + table + ' set ? where ' + _(where).map((value, key) ->
      return mysql.escapeId(key) + ' = ' + mysql.escape(value)
    ).join(' and ')

    mysql.query query, fields, (err, results) ->
      return done err if err?

      done null, results.affectedRows

  _MakeSQLCondition: (value, key) ->
    safeKey = mysql.escapeId key

    # normal case A = B
    if !_.isArray value
      return safeKey + ' = ' + mysql.escape value

    # when passed an array, interpret as an "IN" statement
    # http://dev.mysql.com/doc/refman/5.0/en/comparison-operators.html#function_in
    return safeKey + ' in (' + _(value).map((element) -> mysql.escape element).join(', ') + ')'

module.exports = new Mysql
