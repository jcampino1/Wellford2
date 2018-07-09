class Test < ApplicationRecord
	belongs_to :pump

	validates :diametro_rodete, presence: true

  def self.import(pump, file)
    CSV.foreach(file.path, headers: :true) do |row|
      pump.tests.create!(row.to_hash)
    end
  end
end
