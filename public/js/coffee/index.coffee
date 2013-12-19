traderbot = angular.module 'traderbot', ['ngRoute']

traderbot.config([
  '$routeProvider'
  '$locationProvider'
  ($routeProvider, $locationProvider) ->
    $routeProvider.when '/', {action: 'dashboard'}
    $routeProvider.when '/login', {action: 'login'}
    $routeProvider.when '/logout', {action: 'logout'}
    $routeProvider.when '/bots/:bot', {action: 'bot'}
    $routeProvider.when '/settings/:settings', {action: 'settings'}
    $routeProvider.otherwise redirectTo: '/'

    $locationProvider.html5Mode(true);

]).run([
  '$rootScope'
  '$routeParams'
  '$route'
  '$location'
  ($rootScope, $routeParams, $route, $location) ->
    $rootScope.params = $routeParams
    console.log $routeParams
]);
