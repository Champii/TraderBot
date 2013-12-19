traderbot.factory 'user', [
  ->
    __user
]

traderbot.directive 'tbUsers', [
  '$http'
  '$window'
  '$location'
  'user'
  ($http, $window, $location, user) ->
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

        scope.dashboard = ->
          $location.url '/'


        scope.settings = ->
          $location.url '/settings/general'

        scope.profile = ->
          $location.url '/settings/profile'


    }
]

