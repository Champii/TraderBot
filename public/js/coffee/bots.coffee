
traderbot.service 'botsService', [
  '$rootScope'
  '$routeParams'
  '$location'
  '$route'
  '$http'
  'socket'
  ($rootScope, $routeParams, $location, $route, $http, socket) ->

    @Fetch = ->
      $http.get('/api/1/bots')
        .success (data) =>
          @all = data
          console.log data

        .error (data) ->

    @Add = (bot) ->
      $http.post('/api/1/bots', bot)
        .success (data) ->
          console.log data
        .error (data) ->


    @Init = ->
      @all = []
      @current = null
      @Fetch()

    @Init()

    socket.on 'newBot', (bot) =>
      @all.push bot

    $rootScope.$on '$routeChangeSuccess', =>
      changeTo = $routeParams.bot

      if @current? and @current.name is changeTo
        return

      @current = _(@all).findWhere name: changeTo

      if !(@current?)
        $location.url '/'

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


    }]

