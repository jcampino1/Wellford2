class ChangePumps < ActiveRecord::Migration[5.1]
  def change
    rename_column :pumps, :caudal_minimo, :caudal_minimo_2900
    add_column :pumps, :caudal_minimo_1450, :integer
  end
end
