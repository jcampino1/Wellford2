$(function() {
  $('#container2').highcharts({
    chart: {
      type: 'scatter',
      zoomType: 'xy'
    },
    title: {
      text: 'Evaluacion de puntos'
    },
    subtitle: {
      text: 'Source: Heinz  2003'
    },
    xAxis: {
      title: {
        enabled: true,
        text: 'Caudal (m3)'
      },
      startOnTick: true,
      endOnTick: true,
      showLastLabel: true
    },
    yAxis: {
      title: {
        text: 'Altura (m)'
      }
    },
    legend: {
      layout: 'vertical',
      align: 'left',
      verticalAlign: 'top',
      x: 100,
      y: 70,
      floating: true,
      backgroundColor: '#FFFFFF',
      borderWidth: 1
    },
    plotOptions: {
      scatter: {
        marker: {
          radius: 5,
          states: {
            hover: {
              enabled: true,
              lineColor: 'rgb(100,100,100)'
            }
          }
        },
        states: {
          hover: {
            marker: {
              enabled: false
            }
          }
        },
        tooltip: {
          headerFormat: '<b>{series.name}</b><br>',
          pointFormat: '{point.x} m3, {point.y} m'
        }
      }
    },
    series: [{
      regression: true,
      regressionSettings: {
        type: 'polynomial',
        color: 'rgba(223, 183, 83, .9)',
        dashStyle: 'dash'
      },
      name: 'Test input',
      color: 'rgba(223, 83, 83, .5)',
      data: [
        [38.996, 45.675],
        [34.250, 52.025],
        [29.728, 55.822],
        [21.589, 61.595],
        [12.321, 64.756],
        [1.621, 66.878],
        
       
      ]

    }]
  });
});
