class AddRodetesToPumps < ActiveRecord::Migration[5.1]
  def change
    add_column :pumps, :rodete_max, :integer
    add_column :pumps, :rodete_min, :integer
  end
end
