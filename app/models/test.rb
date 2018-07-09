class Test < ApplicationRecord
	belongs_to :pump

	validates :diametro_rodete, presence: true


  def self.import(pump, file)
    """
    Lee el archivo y crea los tests correspondientes a la bomba seleccionada
    """
    CSV.foreach(file.path, headers: :true) do |row|
      pump.tests.create!(row.to_hash)
    end
  end
end
