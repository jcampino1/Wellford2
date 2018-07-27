class Pump < ApplicationRecord
	has_many :tests

	validates :nombre, presence: true
	validates :rpm, presence: true
	validates :rodete_max, presence: true
	validates :rodete_min, presence: true

  def self.import(file)
    """
    Crea las bombas a partir de la info del csv
    """
    CSV.foreach(file.path, headers: :true) do |row|
      Pump.create!(row.to_hash)
    end
  end

  def self.valida(pump, caudal, altura)
    if pump.valid_tests.length == 0
      return false
    end
    test1 = Test.find
    return true
  end
end
