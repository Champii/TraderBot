traderbot.directive 'tbInputText', [
  '$parse'
  ($parse) ->
    return {
      restrict: 'E'

      replace: true

      templateUrl: 'input-text-tpl'

      link: (scope, element, attr) ->

        getter = $parse(attr.ngModel)
        setter = getter.assign

        $('#edit', element).blur ->
          scope.isEditing = false
          setter(scope.$parent, scope.model)
          scope.$parent.$digest()

        scope.model = getter scope.$parent

        scope.isEditing = false

        scope.toggleEdit = ->
          if !scope.isEditing
            scope.isEditing = true

    }
]
