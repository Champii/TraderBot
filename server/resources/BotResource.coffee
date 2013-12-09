async = require 'async'

botDb = require '../storage/BotDb'
bus = require '../bus'

class BotResource

  constructor: (blob) ->
    if blob?
      @id = blob.id if blob.id?
      @name = blob.name if blob.name?
      @desc = blob.desc if blob.desc?

  Save: (done) ->
    exists = @id?

    botDb.Save @Serialize(), (err, botId) =>
      return done err if err?

      if !exists
        @id = botId
        bus.emit 'newBot', @Serialize()

      done null, @

  Serialize: ->
    id: @id
    name: @name
    desc: @desc

  ToJSON: ->
    id: @id
    name: @name
    desc: @desc

  @Fetch: (id, done) ->
    botDb.Fetch id, (err, blob) =>
      console.log 'bot fetch ', err, blob
      return done err if err?

      BotResource.Deserialize blob, done

  @List: (done) =>
    botDb.List (err, ids) ->
      console.log 'bot list ', err, ids
      return done err if err?

      async.map ids, BotResource.Fetch, done

  @Deserialize: (blob, done) ->
    done null, new BotResource blob

module.exports = BotResource
