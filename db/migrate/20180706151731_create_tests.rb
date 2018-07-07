class CreateTests < ActiveRecord::Migration[5.1]
  def change
    create_table :tests do |t|
      t.float :diametro_rodete
      t.integer :pump_id

      t.timestamps
    end
  end
end
