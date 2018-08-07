class CreatePumps < ActiveRecord::Migration[5.1]
  def change
    create_table :pumps do |t|
      t.string :bomba
      t.float :rpm
      t.string :valid_tests, array: true, default: []
      t.string :curva_rodete_max, array: true, default: []
      t.string :curva_rodete_min, array: true, default: []
      t.string :x_maximos, array: true, default: []
      t.string :frame
      t.string :base
      t.integer :ancho_b1
      t.integer :largo_l1
      t.integer :hs
      t.integer :hd
      t.integer :peso_motobomba
      t.string :efficiency_info_diams, array: true, default: []
      t.integer :a
      t.string :points_max, array: true, default: []
      t.string :points_min, array: true, default: []
      t.string :posibles_motores, array: true, default: []
      t.string :peso, array: true, default: []

      t.timestamps
    end
  end
end
