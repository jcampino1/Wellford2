class AddAToPumps < ActiveRecord::Migration[5.1]
  def change
    add_column :pumps, :a, :integer
  end
end
