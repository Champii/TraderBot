signin = angular.module 'signin', ['ngRoute']

signin.directive 'signin', [
  '$http'
  '$window'
  '$timeout'
  ($http, $window, $timeout) ->
    return {

      restrict: 'E'

      replace: false

      templateUrl: 'signin-form-tpl'

      link: (scope, element, attr) ->

        scope.signin = true

        scope.username = ''
        scope.password = ''

        scope.passwordConf = ''
        scope.email = ''


        scope.error = ''
        scope.message = ''

        scope.toggleSignup = ->
          scope.signin = false

        scope.toggleSignin = ->
          scope.signin = true

        scope.login = ->
          $http.post('/login', {username: scope.username, password: scope.password})
            .success ->
              $window.location.href = '/'
            .error ->
              scope.error = 'Could not login'
              $timeout ->
                scope.error = ''
              , 5000

        scope.register = ->
          $http.post('/signup', {login: scope.username, pass: scope.password, email: scope.email})
            .success ->
              scope.toggleSignin()
              scope.message = 'Successfully registered. Please login'
              $timeout ->
                scope.message = ''
              , 5000
            .error ->
              scope.error = 'Couldnt register. Try again'
              $timeout ->
                scope.error = ''
              , 5000
    }
]