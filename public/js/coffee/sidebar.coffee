traderbot.directive 'tbSidebar', [
  '$http'
  'botsService'
  ($http, botsService) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'sidebar-tpl'

      link: (scope, element, attr) ->
        scope.bots = botsService

    }]

