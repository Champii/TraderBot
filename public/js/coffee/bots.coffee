
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

    @Save = (bot) ->
      $http.put('/api/1/bots/' + bot.id, bot)
        .success (data) ->
          console.log data
        .error (data) ->
          console.log data

    @Init = ->
      @all = []
      @current = null
      @Fetch()

    @Init()

    socket.on 'newBot', (bot) =>
      @all.push bot

    socket.on 'updateBot', (bot) =>
      console.log 'bot', bot
      toUpdate = _(@all).findWhere {id: bot.id}

      console.log 'ToUpdate = ', toUpdate
      if toUpdate
        _(toUpdate).each (value, key) ->
          if toUpdate[key] isnt bot[key]
            toUpdate[key] = bot[key]
        console.log 'Updated = ', toUpdate
        $rootScope.$emit 'updateBot'

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
  '$rootScope'
  '$http'
  'botsService'
  ($rootScope, $http, botsService) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'bots-tpl'

      link: (scope, element, attr) ->
        scope.bots = botsService

        $rootScope.$on 'updateBot', ->
          console.log scope.bots
          # scope.$digest()

        $http.get('/api/1/availableMarket')
          .success (data) ->
            scope.availableMarket = data

        $http.get('/api/1/availablePair')
          .success (data) ->
            scope.availablePair = data

        scope.startStop = ->
          status = if scope.bots.current.active then 'start' else 'stop'
          $http.get('/api/1/bots/' + scope.bots.current.id + '/' + status)
            .success ->
              console.log 'Success'
            .error ->
              console.log 'Error'

        scope.save = ->
          console.log 'Save'
          scope.bots.Save scope.bots.current

    }]

