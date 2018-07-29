class AddSearchingInfoToPumps < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :curva_rodete_max, :string, array: true, default: []
  	add_column :pumps, :curva_rodete_min, :string, array: true, default: []
  	add_column :pumps, :x_maximos, :string, array: true, default: []
  end
end
