toggleCount = 0
traderbot.directive 'tbToggle', [
  '$timeout'
  ($timeout) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'toggle-tpl'

      scope:
        change: '='
        value: '='

      link: (scope, element, attr) ->
        scope.count = toggleCount++

        scope.changed = ->
          if scope.change
            $timeout ->
              scope.change scope.value
            , 500

    }
]
