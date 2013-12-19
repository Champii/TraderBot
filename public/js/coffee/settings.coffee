traderbot.directive 'tbSettings', [
  '$http'
  '$window'
  'user'
  ($http, $window, user) ->
    return {

      restrict: 'E'

      replace: true

      templateUrl: 'settings-tpl'

      link: (scope, element, attr) ->
        scope.user = user
        console.log user

        scope.save = ->
          console.log 'Save', scope.user
          $http.put('/api/1/user', scope.user)
            .success ->
              console.log 'Success'
            .error ->
              console.log 'Error'

    }
]
