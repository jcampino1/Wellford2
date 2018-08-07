class CreateIntersections < ActiveRecord::Migration[5.1]
  def change
    create_table :intersections do |t|
      t.integer :succion
      t.integer :descarga
      t.integer :pump_id
      t.integer :motor_id
      t.float :rodete_max
      t.float :rodete_min
      t.string :machon_omega
      t.string :machon_dentado
      t.string :anillo_delantero
      t.string :anillo_trasero
      t.string :bomba_delantero
      t.string :bomba_trasero
      t.string :acople_machon
      t.string :acople_motor
      t.integer :caudal_minimo

    end
  end
end
