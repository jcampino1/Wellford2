class CreateMotors < ActiveRecord::Migration[5.1]
  def change
    create_table :motors do |t|
      t.float :rpm
      t.integer :kw
      t.integer :hp
      t.string :frame
      t.string :machon_omega
      t.string :machon_dentado
      t.string :rod_delantero
      t.string :rod_trasero
    end
  end
end
