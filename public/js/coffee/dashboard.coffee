traderbot.directive 'tbDashboard', [
  '$rootScope'
  '$http'
  'botsService'
  ($rootScope, $http, botsService) ->
    return {
      restrict: 'E'

      replace: false

      templateUrl: 'dashboard-tpl'

      link: (scope, element, attr) ->
        $http.get('/api/1/dashboard/balances')
          .success (data) ->
            scope.balances = data
          .error ->
            console.error 'Error'
    }
]
