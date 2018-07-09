require 'matrix'
require 'csv'

module TestsHelper

	def grafico_circular curva_h
		scatter_chart curva_h, regression: true, regressionSettings: {type: 'polynomial'}, height: '500px', width: '500px',	series: [{
	      name: "Rodete 214",
	      regression: true,
	      regressionSettings: {
	        type: 'polynomial',
	        color: 'rgba(223, 183, 83, .9)',
	        dashStyle: 'dash'
	      },
	      data: curva_h
	    }],

		library: {
			title: {
		      text: 'Evaluacion de puntos'
		    },
		    subtitle: {
		      text: 'Elije los puntos que quieras sacar'
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
		          pointFormat: '{point.x} cm, {point.y} kg'
		        }
		      }
		    }
		}
	end

 
	def regression x, y, degree
	  x_data = x.map { |xi| (0..degree).map { |pow| (xi**pow).to_r } }
	 
	  mx = Matrix[*x_data]
	  my = Matrix.column_vector(y)
	 
	  ((mx.t * mx).inv * mx.t * my).transpose.to_a[0].map(&:to_f)
	end

	# Se usa de la siguinte forma:
	# p regression([lista x], [lista y], grado)
	# Output: lista con coeficientes


	# Falta que lea mas decimales, lee los numeros con 1 decimal
	def abrir_archivo archivo
		caud = []
		altu = []
		efi = []
		pot = []
		CSV.foreach(archivo) do |linea|
			p linea
			caud.push(linea[0].to_f)
			altu.push(linea[1].to_f)
			efi.push(linea[2].to_f)
			pot.push(linea[3].to_f)
		end
		return caud, altu, efi, pot
	end
end