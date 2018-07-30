class AddAttributesToPump < ActiveRecord::Migration[5.1]
  def change
    add_column :pumps, :succion, :integer
    add_column :pumps, :descarga, :integer
    add_column :pumps, :motor_hp, :integer
    add_column :pumps, :frame, :string
    add_column :pumps, :base, :string
    add_column :pumps, :machon_omega, :string
    add_column :pumps, :machon_dentado, :string
    add_column :pumps, :anillo_delantero, :string
    add_column :pumps, :anillo_trasero, :string
    add_column :pumps, :delantero_motor, :string
    add_column :pumps, :trasero_motor, :string
    add_column :pumps, :delantero_bomba, :string
    add_column :pumps, :trasero_bomba, :string
    add_column :pumps, :caudal_minimo, :integer
    add_column :pumps, :ancho_b1, :integer
    add_column :pumps, :largo_l1, :integer
    add_column :pumps, :hs, :integer
    add_column :pumps, :hd, :integer
    add_column :pumps, :peso_motobomba, :integer
    add_column :pumps, :acople_machon, :integer
    add_column :pumps, :acople_motor, :integer
  end
end
