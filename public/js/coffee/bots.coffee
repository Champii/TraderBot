traderbot.service 'botsService', [
  '$http'
  'socket'
  ($http, socket) ->

    @Fetch = ->
      $http.get('/api/1/bots')
        .success (data) =>
          @all = data

        .error (data) ->

    @Init = ->
      @all = []
      @Fetch()

    socket.on 'newBot', (bot) =>
      @all.push bot

    @Init()

    return @
]

traderbot.directive 'tbBots', [
  '$http'
  'botsService'
  ($http, botsService) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'bots-tpl'

      link: (scope, element, attr) ->
        scope.bots = botsService

        scope.newName = ''

        scope.debug = ->
          console.log scope.bots

        scope.add = ->
          $http.post('/api/1/bots', {name: scope.newName})
            .success (data) ->
              console.log data
            .error (data) ->


    }]

