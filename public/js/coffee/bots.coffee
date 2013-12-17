traderbot.service 'botsService', [
  '$rootScope'
  '$routeParams'
  '$location'
  '$route'
  '$http'
  'socket'
  'user'
  ($rootScope, $routeParams, $location, $route, $http, socket, user) ->

    @Fetch = ->
      $http.get('/api/1/bots')
        .success (data) =>
          @all = data
        .error (data) ->

    @Add = (bot) ->
      console.log user
      bot.user_id = user.id
      $http.post('/api/1/bots', bot)
        .success (data) ->
          1
        .error (data) ->
          1

    @Save = (bot) ->
      bot.user_id = user.id
      $http.put('/api/1/bots/' + bot.id, bot)
        .success (data) ->
          1
        .error (data) ->
          1

    @GetMarkets = (done) ->
      $http.get('/api/1/markets')
        .success (data) ->
          return done null, data

    @GetPairs = (marketId, done) ->
      $http.get('/api/1/markets/' + marketId + '/pairs')
        .success (data) ->
          return done null, data

    @Init = ->
      @all = []
      @current = null
      @Fetch()

    @Init()

    socket.on 'newBot', (bot) =>
      @all.push bot

    socket.on 'updateBot', (bot) =>
      toUpdate = _(@all).findWhere {id: bot.id}

      if toUpdate
        _(toUpdate).each (value, key) ->
          if toUpdate[key] isnt bot[key]
            toUpdate[key] = bot[key]

    $rootScope.$on '$routeChangeSuccess', =>
      changeTo = $routeParams.bot

      if @current? and @current.name is changeTo
        return

      @current = _(@all).findWhere name: changeTo

      if !(@current?)
        $location.url '/'
      else
        $rootScope.$emit 'botChanged'

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

        $rootScope.$on 'botChanged', ->

          scope.bots.GetMarkets (err, markets) ->
            scope.availableMarket = markets
            scope.bots.GetPairs _(markets).findWhere({name: scope.bots.current.market}).id, (err, pairs) ->
              scope.availablePair = pairs


          # $http.get('/api/1/markets')
          #   .success (data) ->
          #     scope.availableMarket = data

          #     $http.get('/api/1/markets/' + _(scope.availableMarket).findWhere({name: scope.bots.current.market}).id + '/pairs')
          #       .success (data) ->
          #         scope.availablePair = data

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

        scope.fetchPairs = ->
          scope.save()
          $http.get('/api/1/markets/' + _(scope.availableMarket).findWhere({name: scope.bots.current.market}).id + '/pairs')
            .success (data) ->
              scope.availablePair = data
              existsAgain = _(scope.availablePair).chain()
                                .pluck('pair')
                                .contains(scope.bots.current.pair)
                                .value()

              if !existsAgain
                scope.bots.current.pair = scope.availablePair[0].pair


    }]

