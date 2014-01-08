traderbot.directive 'tbOrders', [
  '$rootScope'
  '$http'
  'botsService'
  'socket'
  ($rootScope, $http, botsService, socket) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'orders-tpl'

      link: (scope, element, attr) ->

        socket.on 'newOrder', (order) ->
          if order.bot_id isnt botsService.current.id
            return

          if scope.orders.length > 10
            scope.orders.pop()
          scope.orders.unshift order

        refreshOrders = ->
          $http.get('/api/1/bots/' + botsService.current.id + '/orders')
            .success (data) ->
              scope.orders = data

        $rootScope.$on 'botChanged', ->
          refreshOrders()

        refreshOrders()
    }
]
