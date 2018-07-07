class Test < ApplicationRecord
	belongs_to :pump

	validates :diametro_rodete, presence: true
end
