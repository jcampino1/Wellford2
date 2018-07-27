class AddSearchingInfoToPumps < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :searching_info, :string, array: true, default: []
  end
end
