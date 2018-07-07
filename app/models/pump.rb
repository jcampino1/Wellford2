class Pump < ApplicationRecord
	has_many :tests

	validates :nombre, presence: true
  	validates :rpm, presence: true
  	validates :rodete_max, presence: true
  	validates :rodete_min, presence: true
end
