traderbot = angular.module 'traderbot', ['ngRoute']

traderbot.config [
  '$routeProvider'
  '$locationProvider'
  ($routeProvider, $locationProvider) ->
    $routeProvider.when '/', {action: 'home'}
    $routeProvider.when '/:bot', {action: 'bot'}
    $routeProvider.otherwise redirectTo: '/'

    $locationProvider.html5Mode(true);

]
