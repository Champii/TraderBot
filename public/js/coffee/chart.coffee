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

        lastTime = Math.floor((new Date().getTime() - 10000000) / 1000)

        scope.updateChart = (done) ->
          # console.log scope
          if botsService.current?
            # console.log scope.availableMarket, scope.availablePair, botsService.current
            market = _(scope.availableMarket).findWhere({name: botsService.current.market}).id
            pair = _(scope.availablePair).findWhere({pair: botsService.current.pair}).id
            $http.get('/api/1/markets/' + market + '/pairs/' + pair + '/chart/' + lastTime)
              .success (data) ->
                lastTime = Math.floor(new Date().getTime() / 1000)
                done null, data
              .error (data) ->
                done data

        $rootScope.$on 'botChanged', ->
          console.log 'Bot Changed'
          # scope.updateChart()


        initChart = (done) ->
          botsService.GetMarkets (err, markets) ->
            scope.availableMarket = markets
            botsService.GetPairs _(markets).findWhere({name: botsService.current.market}).id, (err, pairs) ->
              scope.availablePair = pairs
              scope.updateChart (err, data) =>
                return done err if err?

                properData = []
                candleData = []
                _(data).each (value) ->
                  properData.push [value.time, value.value.last]

                count = 0
                currentH = 0
                currentL = 0
                currentO = 0
                currentC = 0
                time = 0
                _(data).each (value) ->
                  if count is 60
                    currentC = value.value.last
                    candleData.push [time, currentO, currentH, currentL, currentC]
                    currentH = 0
                    currentL = 0
                    currentO = 0
                    currentC = 0
                    count = 0
                  else
                    if !count
                      currentO = value.value.last
                      currentL = currentO
                      time = value.time
                    if value.value.last > currentH
                      currentH = value.value.last
                    if value.value.last < currentL
                      currentL = value.value.last
                    count++

                Highcharts.theme = {
                   colors: ["#DDDF0D", "#7798BF", "#55BF3B", "#DF5353", "#aaeeee", "#ff0066", "#eeaaee",
                      "#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
                   chart: {
                      backgroundColor: {
                         linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                         stops: [
                            [0, 'rgb(96, 96, 96)'],
                            [1, 'rgb(16, 16, 16)']
                         ]
                      },
                      borderWidth: 0,
                      borderRadius: 15,
                      plotBackgroundColor: null,
                      plotShadow: false,
                      plotBorderWidth: 0
                   },
                   title: {
                      style: {
                         color: '#FFF',
                         font: '16px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
                      }
                   },
                   subtitle: {
                      style: {
                         color: '#DDD',
                         font: '12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
                      }
                   },
                   xAxis: {
                      gridLineWidth: 0,
                      lineColor: '#999',
                      tickColor: '#999',
                      labels: {
                         style: {
                            color: '#999',
                            fontWeight: 'bold'
                         }
                      },
                      title: {
                         style: {
                            color: '#AAA',
                            font: 'bold 12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
                         }
                      }
                   },
                   yAxis: {
                      alternateGridColor: null,
                      minorTickInterval: null,
                      gridLineColor: 'rgba(255, 255, 255, .1)',
                      minorGridLineColor: 'rgba(255,255,255,0.07)',
                      lineWidth: 0,
                      tickWidth: 0,
                      labels: {
                         style: {
                            color: '#999',
                            fontWeight: 'bold'
                         }
                      },
                      title: {
                         style: {
                            color: '#AAA',
                            font: 'bold 12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
                         }
                      }
                   },
                   legend: {
                      itemStyle: {
                         color: '#CCC'
                      },
                      itemHoverStyle: {
                         color: '#FFF'
                      },
                      itemHiddenStyle: {
                         color: '#333'
                      }
                   },
                   labels: {
                      style: {
                         color: '#CCC'
                      }
                   },
                   tooltip: {
                      backgroundColor: {
                         linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                         stops: [
                            [0, 'rgba(96, 96, 96, .8)'],
                            [1, 'rgba(16, 16, 16, .8)']
                         ]
                      },
                      borderWidth: 0,
                      style: {
                         color: '#FFF'
                      }
                   },


                   plotOptions: {
                      series: {
                         shadow: true
                      },
                      line: {
                         dataLabels: {
                            color: '#CCC'
                         },
                         marker: {
                            lineColor: '#333'
                         }
                      },
                      spline: {
                         marker: {
                            lineColor: '#333'
                         }
                      },
                      scatter: {
                         marker: {
                            lineColor: '#333'
                         }
                      },
                      candlestick: {
                         lineColor: 'white'
                      }
                   },

                   toolbar: {
                      itemStyle: {
                         color: '#CCC'
                      }
                   },

                   navigation: {
                      buttonOptions: {
                         symbolStroke: '#DDDDDD',
                         hoverSymbolStroke: '#FFFFFF',
                         theme: {
                            fill: {
                               linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                               stops: [
                                  [0.4, '#606060'],
                                  [0.6, '#333333']
                               ]
                            },
                            stroke: '#000000'
                         }
                      }
                   },

                   rangeSelector: {
                      buttonTheme: {
                         fill: {
                            linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                            stops: [
                               [0.4, '#888'],
                               [0.6, '#555']
                            ]
                         },
                         stroke: '#000000',
                         style: {
                            color: '#CCC',
                            fontWeight: 'bold'
                         },
                         states: {
                            hover: {
                               fill: {
                                  linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                  stops: [
                                     [0.4, '#BBB'],
                                     [0.6, '#888']
                                  ]
                               },
                               stroke: '#000000',
                               style: {
                                  color: 'white'
                               }
                            },
                            select: {
                               fill: {
                                  linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                  stops: [
                                     [0.1, '#000'],
                                     [0.3, '#333']
                                  ]
                               },
                               stroke: '#000000',
                               style: {
                                  color: 'yellow'
                               }
                            }
                         }
                      },
                      inputStyle: {
                         backgroundColor: '#333',
                         color: 'silver'
                      },
                      labelStyle: {
                         color: 'silver'
                      }
                   },

                   navigator: {
                      handles: {
                         backgroundColor: '#666',
                         borderColor: '#AAA'
                      },
                      outlineColor: '#CCC',
                      maskFill: 'rgba(16, 16, 16, 0.5)',
                      series: {
                         color: '#7798BF',
                         lineColor: '#A6C7ED'
                      }
                   },

                   scrollbar: {
                      barBackgroundColor: {
                            linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                            stops: [
                               [0.4, '#888'],
                               [0.6, '#555']
                            ]
                         },
                      barBorderColor: '#CCC',
                      buttonArrowColor: '#CCC',
                      buttonBackgroundColor: {
                            linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                            stops: [
                               [0.4, '#888'],
                               [0.6, '#555']
                            ]
                         },
                      buttonBorderColor: '#CCC',
                      rifleColor: '#FFF',
                      trackBackgroundColor: {
                         linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                         stops: [
                            [0, '#000'],
                            [1, '#333']
                         ]
                      },
                      trackBorderColor: '#666'
                   },

                   legendBackgroundColor: 'rgba(48, 48, 48, 0.8)',
                   legendBackgroundColorSolid: 'rgb(70, 70, 70)',
                   dataLabelsColor: '#444',
                   textColor: '#E0E0E0',
                   maskColor: 'rgba(255,255,255,0.3)'
                };

                highchartsOptions = Highcharts.setOptions(Highcharts.theme);

                $('#chart', element).highcharts 'StockChart',
                  chart :
                    events :
                      load : ->
                        setInterval =>
                          scope.updateChart (err, data) =>
                            return console.error err if err?
                            _(data).each (value, key) =>
                              this.series[0].addPoint [value.time, value.value.last], false, false
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
                    text : 'Live Data'

                  exporting:
                    enabled: false

                  series : [{
                    type: 'spline'
                    name : 'Live Data'
                    data : properData
                  },{
                    type: 'candlestick'
                    name: 'candle'
                    data: candleData
                  }]


        initChart (err) =>
          console.error err if err?
    }
]
