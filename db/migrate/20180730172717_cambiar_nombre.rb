class CambiarNombre < ActiveRecord::Migration[5.1]
  def change
    rename_column :pumps, :nombre, :bomba
  end
end
