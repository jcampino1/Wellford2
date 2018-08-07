class CreatePumps < ActiveRecord::Migration[5.1]
  def change
    create_table :pumps do |t|
      t.string :bomba
      t.float :rpm
      t.string :valid_tests, array: true, default: []
      t.string :curva_rodete_max, array: true, default: []
      t.string :curva_rodete_min, array: true, default: []
      t.string :x_maximos, array: true, default: []
      t.string :efficiency_info_diams, array: true, default: []
      t.string :points_max, array: true, default: []
      t.string :points_min, array: true, default: []
      t.string :posibles_hp, array: true, default: []
      t.string :posibles_kw, array: true, default: []
      t.string :posibles_motores, array: true, default: []
      t.integer :succion
      t.integer :descarga
      t.float :rodete_max
      t.float :rodete_min
      t.string :anillo_delantero
      t.string :anillo_trasero
      t.string :bomba_delantero
      t.string :bomba_trasero
      t.integer :caudal_minimo

      t.timestamps
    end
  end
end
