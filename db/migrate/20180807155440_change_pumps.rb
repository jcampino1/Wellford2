class ChangePumps < ActiveRecord::Migration[5.1]
  def change
    rename_column :pumps, :posibles_motores, :posibles_hp
    add_column :pumps, :posibles_kw, :string, array: true, default: []
    add_column :pumps, :posibles_motores, :string, array: true, default: []
  end
end
