class AddCurrenthToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :current_h, :string, array: true, default: []
  end
end
