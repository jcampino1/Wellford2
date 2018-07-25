class AddCurrenth < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :current_e, :string, array: true, default: []
    add_column :tests, :current_p, :string, array: true, default: []


  end
end
