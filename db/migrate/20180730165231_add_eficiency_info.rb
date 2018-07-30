class AddEficiencyInfo < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :efficiency_info, :string, array: true, default: []
  end
end
