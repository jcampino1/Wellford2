class CreatePumps < ActiveRecord::Migration[5.1]
  def change
    create_table :pumps do |t|
      t.string :nombre
      t.float :rpm
      t.float :rodete_max
      t.float :rodete_min

      t.timestamps
    end
  end
end
