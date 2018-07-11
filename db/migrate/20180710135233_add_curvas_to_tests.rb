class AddCurvasToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :curva_h, :string, array: true, default: []
    add_column :tests, :curva_e, :string, array: true, default: []
    add_column :tests, :curva_p, :string, array: true, default: []
  end
end
