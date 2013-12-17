traderbot.directive 'tbSidebar', [
  'botsService'
  (botsService) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'sidebar-tpl'

      link: (scope, element, attr) ->
        scope.bots = botsService

        scope.botName = ''

        scope.show = false

        scope.toggleAdd = ->
          scope.show = !scope.show

        scope.addBot = ->
          scope.bots.Add {name: scope.botName}


    }]

