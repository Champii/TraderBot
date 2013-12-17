traderbot.factory 'user', [
  ->
    __user
]

traderbot.directive 'users', [
  '$http'
  '$window'
  'user'
  ($http, $window, user) ->
    return {

      restrict: 'E'

      replace: true

      templateUrl: 'users-tpl'

      link: (scope, element, attr) ->
        scope.user = user

        scope.logout = ->
          $http.post('/logout')
            .success (data) ->
              console.log 'Success'
              $window.location.href = '/'

    }
]

