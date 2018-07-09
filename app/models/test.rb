class Test < ApplicationRecord
	belongs_to :pump

	validates :diametro_rodete, presence: true

	def self.import(pump, file)
	#CSV.foreach(file.path, headers: :true) do |row|
	  #pump.tests.create!(row.to_hash)
		diametro = 0
		caud = []
		altu = []
		efi = []
		pot = []
		CSV.foreach(file.path, headers: :true) do |linea|
			if linea[0] != NIL
				diametro = linea[0].to_f
			end
			caud.push(linea[1].to_f)
			altu.push(linea[2].to_f)
			efi.push(linea[3].to_f)
			pot.push(linea[4].to_f)
		end
		#pump.tests.create!({:diametro_rodete => diametro})
		return diametro, caud, altu, efi, pot
	end
end
