traderbot.service 'bots', [
  '$http'
  ($http) ->
    @Fetch = ->
      $http.get('/api/1/bots')
        .success (data) ->
          console.log data
        .error (data) ->
          console.log data

    @Init = =>
      @all = []
      @Fetch()

    @Init()
]

traderbot.directive 'tbBots', [
  '$http'
  'bots'
  ($http, bots) ->
    return {
      restrict: 'E'

      replace: false

      templateUrl: 'bots-tpl'

      link: (scope, element, attr) ->
        scope.bots = bots

        scope.newName = ''

        scope.add = ->


    }]

