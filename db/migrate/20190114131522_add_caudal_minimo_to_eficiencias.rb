class AddCaudalMinimoToEficiencias < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :caudal_minimo_eficiencia, :float
  end
end
