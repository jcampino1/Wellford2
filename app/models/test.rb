class Test < ApplicationRecord
	belongs_to :pump

	validates :diametro_rodete, presence: true
  
	def self.import(pump, file)
	#CSV.foreach(file.path, headers: :true) do |row|
	  #pump.tests.create!(row.to_hash)
		diametro = 0
		curva_h = []
		curva_e = []
		curva_p = []
		CSV.foreach(file.path, headers: :true) do |linea|
			if linea[0] != NIL
				diametro = linea[0].to_f
			end
			curva_h.push([linea[1].to_f, linea[2].to_f])
			curva_e.push([linea[1].to_f, linea[3].to_f])
			curva_p.push([linea[1].to_f, linea[4].to_f])
		end
		#pump.tests.create!({:diametro_rodete => diametro})
		return diametro, curva_h.reverse, curva_e.reverse, curva_p.reverse
	end
end
