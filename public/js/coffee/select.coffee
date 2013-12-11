selectCount = 0
traderbot.directive 'tbSelect', [
  '$http'
  ($http) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'select-tpl'

      scope:
        disableEdit: '='
        options: '='
        onSave: '='
        value: '='

      link: (scope, element, attr) ->

        scope.isEditing = false

        scope.buttonLabel = 'Edit'

        scope.count = toggleCount++

        scope.toggleEdit = ->
          if scope.isEditing
            scope.buttonLabel = 'Edit'
            if scope.onSave
              scope.onSave scope.value
          else
            scope.buttonLabel = 'Save'
          scope.isEditing = !scope.isEditing

    }
]
