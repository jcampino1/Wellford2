class CreateIntersections < ActiveRecord::Migration[5.1]
  def change
    create_table :intersections do |t|
      t.integer :pump_id
      t.integer :motor_id
      t.string :base
      t.integer :ancho_b1
      t.integer :largo_l1
      t.integer :hs
      t.integer :hd
      t.integer :a
      t.integer :peso

    end
  end
end
