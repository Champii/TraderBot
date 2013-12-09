traderbot.factory 'socket', [
  '$rootScope'
  ($rootScope) ->
    socket = io.connect()

    return {
      on: (eventName, callback) ->
        wrapper = () ->
          args = arguments
          onLast = args[args.length - 1]

          if onLast > lastEvent
            lastEvent = onLast

          $rootScope.$apply ->
            callback.apply socket, args

        socket.on eventName, wrapper

        return ->
          socket.removeListener eventName, wrapper

      emit: (eventName, data, callback) ->
        socket.emit eventName, data, ->
          args = arguments
          $rootScope.$apply ->
            callback.apply socket, args if callback?
    }]
