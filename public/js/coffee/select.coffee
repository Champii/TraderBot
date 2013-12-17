selectCount = 0
editing = {editing: false}
traderbot.directive 'tbSelect', [
  '$http'
  ($http) ->
    return {
      restrict: 'E'

      replace: false

      templateUrl: 'select-tpl'

      scope:
        disableEdit: '='
        optionsFn: '&options'
        onSave: '='
        value: '='

      link: (scope, element, attr) ->

        scope.editing = editing

        scope.isEditing = false

        scope.buttonLabel = 'Edit'

        scope.count = toggleCount++

        scope.toggleEdit = ->
          if scope.isEditing
            scope.buttonLabel = 'Edit'
            if scope.onSave
              scope.onSave scope.value
            scope.editing.editing = false
          else
            scope.options = scope.optionsFn()
            if attr.key
              scope.options = _(scope.options).pluck(attr.key)
            scope.buttonLabel = 'Save'
            scope.editing.editing = true
          scope.isEditing = !scope.isEditing

    }
]
