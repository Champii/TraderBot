traderbot.directive 'tbTrades', [
  '$rootScope'
  '$http'
  'botsService'
  ($rootScope, $http, botsService) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'trades-tpl'

      link: (scope, element, attr) ->

        refreshTrades = ->
          $http.get('/api/1/bots/' + botsService.current.id + '/trades')
            .success (data) ->
              scope.trades = data

        $rootScope.$on 'botChanged', ->
          refreshTrades()

        refreshTrades()
    }
]
