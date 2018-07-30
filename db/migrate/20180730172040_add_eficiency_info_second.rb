class AddEficiencyInfoSecond < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :efficiency_info_diams, :string, array: true, default: []
  end
end
