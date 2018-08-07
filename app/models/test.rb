require 'matrix'

class Test < ApplicationRecord
	belongs_to :pump

	validates :diametro_rodete, presence: true
  
	def self.import(pump, file)
	#CSV.foreach(file.path, headers: :true) do |row|
	  #pump.tests.create!(row.to_hash)
	  	nombre = ''
	  	numero_pedido = 0
		diametro = 0
		curva_h = []
		curva_e = []
		CSV.foreach(file.path, headers: :true) do |linea|
			if linea[0] != NIL
				nombre = linea[0]
			end
			if linea[1] != NIL
				numero_pedido = linea[1].to_f
			end
			if linea[2] != NIL
				diametro = linea[2].to_f
			end

			curva_h.push([linea[3].to_f, linea[4].to_f])
			curva_e.push([linea[3].to_f, linea[5].to_f])
		end
		return nombre, numero_pedido, diametro, curva_h.reverse, curva_e.reverse
	end

	def self.pasar_a_numero lista
		nueva_lista = []
		lista.each do |punto|
			nueva_lista.push([punto[0].to_f, punto[1].to_f])
		end
		return nueva_lista
	end

	def self.regression datos, degree
		x = []
		y = []

		for dato in datos
			x.push(dato[0].to_f)
			y.push(dato[1].to_f)
		end

		x_data = x.map { |xi| (0..degree).map { |pow| (xi**pow).to_r } }
	 
		mx = Matrix[*x_data]
		my = Matrix.column_vector(y)
	 
		((mx.t * mx).inv * mx.t * my).transpose.to_a[0].map(&:to_f)
	end

end
