userDb = require '../storage/UserDb'

class UserResource

  constructor: (blob) ->
    @id = blob.id if blob.id?
    @login = blob.login if blob.login?
    @pass = blob.pass if blob.pass?
    @email = blob.email if blob.email?
    @group = blob.group || 1
    @settings = JSON.parse blob.settings if blob.settings?
    @settings = @DefaultSettings() if !(blob.settings?)

  ValidatePassword: (password) ->
    return if password is @pass then true else false

  Save: (done) ->
    exists = @id?
    console.log 'SaveUser, ', @Serialize()
    userDb.Save @Serialize(), (err, userId) =>
      return done err if err?

      if !exists
        @id = userId

      done null, @

  Serialize: ->
    id: @id
    login: @login
    pass: @pass
    email: @email
    group: @group
    settings: JSON.stringify @settings

  ToJSON: ->
    id: @id
    login: @login
    pass: @pass
    email: @email
    group: @group
    settings: @settings


  DefaultSettings: ->
    keys: [{
      name: 'btce'
      key: ''
      secret: ''},
      {name: 'mtgox'
      key: ''
      secret: ''}]


  @Fetch: (id, done) ->
    userDb.Fetch id, (err, blob) ->
      return done err if err?

      UserResource.Deserialize blob, done

  @FetchByLogin: (login, done) ->
    userDb.FetchByLogin login, (err, blob) ->
      return done err if err?

      UserResource.Deserialize blob, done

  @List: (done) ->
    userDb.List (err, ids) ->
      return done err if err?

      async.map _(ids).pluck('id'), UserResource.Fetch, done

  @Deserialize: (blob, done) ->
    done null, new UserResource blob

module.exports = UserResource

