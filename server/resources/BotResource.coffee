async = require 'async'

botDb = require '../storage/BotDb'

class BotResource

  constructor: (blob) ->
    @id = blob.id if blob.id?

  Save: (done) ->
    botDb.Save @Serialize(), done

  Serialize: ->
    id: @id
    name: @name

  ToJSON: ->
    id: @id
    name: @name

  @Fetch: (id, done) ->
    botDb.Fetch id, (err, blob) =>
      return done err if err

      @Deserialize blob, done

  @List: (done) =>
    botDb.List (err, ids) ->
      return done err if err?

      async.map ids, BotResource.Fetch, done

  @Deserialize: (blob, done) ->
    done null, new BotResource blob

module.exports = BotResource
