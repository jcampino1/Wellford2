class AddPointsToMaxAndMin < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :points_max, :string, array: true, default: []
  	add_column :pumps, :points_min, :string, array: true, default: []
  end
end
