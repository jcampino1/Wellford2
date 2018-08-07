class CreateTests < ActiveRecord::Migration[5.1]
  def change
    create_table :tests do |t|
      t.string :nombre
      t.float :numero_pedido
      t.float :diametro_rodete
      t.integer :pump_id
      t.string :curva_h, array: true, default: []
      t.string :curva_e, array: true, default: []
      t.string :current_h, array: true, default: []
      t.string :current_e, array: true, default: []
      t.string :coefficients_h, array: true, default: []
      t.string :coefficients_e, array: true, default: []
      t.string :xmaximos, array: true, default: []

      t.timestamps
    end
  end
end
