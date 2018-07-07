require 'matrix'

module TestsHelper

 
	def regression x, y, degree
	  x_data = x.map { |xi| (0..degree).map { |pow| (xi**pow).to_r } }
	 
	  mx = Matrix[*x_data]
	  my = Matrix.column_vector(y)
	 
	  ((mx.t * mx).inv * mx.t * my).transpose.to_a[0].map(&:to_f)
	end

	# Se usa de la siguinte forma:
	# p regression([lista x], [lista y], grado)
	# Output: lista con coeficientes



	# def abrir_archivo archivo
	# Que entrege listas con los correspondientes caudales,
	# alturas, eficiencias y potencias.
end


