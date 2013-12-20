traderbot.directive 'tbTrades', [
  '$rootScope'
  '$http'
  'botsService'
  'socket'
  ($rootScope, $http, botsService, socket) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'trades-tpl'

      link: (scope, element, attr) ->

        # scope.trades = []

        socket.on 'newTrade', (trade) ->
          if scope.trades.length > 10
            scope.trades.pop()
          scope.trades.unshift trade

        refreshTrades = ->
          $http.get('/api/1/bots/' + botsService.current.id + '/trades')
            .success (data) ->
              scope.trades = data

        $rootScope.$on 'botChanged', ->
          refreshTrades()

        refreshTrades()
    }
]
