traderbot.directive 'tbChart', [
  '$rootScope'
  '$http'
  'botsService'
  ($rootScope, $http, botsService) ->
    return {
      restrict: 'E'

      replace: false

      templateUrl: 'chart-tpl'

      link: (scope, element, attr) ->

        chartData = []
        lastTime = Math.floor((new Date().getTime() - 100000) / 1000)

        botsService.GetMarkets (err, markets) ->
          scope.availableMarket = markets
          botsService.GetPairs _(markets).findWhere({name: botsService.current.market}).id, (err, pairs) ->
            scope.availablePair = pairs
            scope.updateChart()

        initChart = (done) ->


        scope.updateChart = (serie, chart) ->
          # console.log scope
          if botsService.current?
            # console.log scope.availableMarket, scope.availablePair, botsService.current
            market = _(scope.availableMarket).findWhere({name: botsService.current.market}).id
            pair = _(scope.availablePair).findWhere({pair: botsService.current.pair}).id
            $http.get('/api/1/markets/' + market + '/pairs/' + pair + '/chart/' + lastTime)
              .success (data) ->
                _(data).each (value, key) ->
                  console.log key, value
                  if serie?
                    serie.addPoint [value.time, value.value.last], false, false
                  else
                    chartData.push [value.time, value.value.last]
                chart.redraw()
                lastTime = Math.floor(new Date().getTime() / 1000)
              .error ->
                console.error 'Error'

        $rootScope.$on 'botChanged', ->
          console.log 'Bot Changed'
          # scope.updateChart()

        Highcharts.setOptions({
          global : {
            useUTC : false
          }
        });

        $('#chart', element).highcharts 'StockChart',
          chart :
            events :
              load : ->
                # series = this.series[0]
                setInterval =>
                  scope.updateChart this.series[0], this
                , 1000

          rangeSelector:
            buttons: [{
              count: 1
              type: 'minute'
              text: '1M'
            }, {
              count: 5
              type: 'minute'
              text: '5M'
            }, {
              type: 'all'
              text: 'All'
            }]
            inputEnabled: false
            selected: 0

          title :
            text : 'Live random data'

          exporting:
            enabled: false

          series : [{
            name : 'Random data'
            # type : 'candlestick'
            data : (->
              [0, 0]
            )()
          }]

    }
]
