traderbot = angular.module 'traderbot', ['ngRoute']

traderbot.config [
  '$routeProvider'
  '$locationProvider'
  ($routeProvider, $locationProvider) ->
    $routeProvider.when '/login', {action: 'login'}
    $routeProvider.when '/logout', {action: 'logout'}
    $routeProvider.when '/:bot', {action: 'bot'}
    $routeProvider.otherwise redirectTo: '/'

    $locationProvider.html5Mode(true);

]
