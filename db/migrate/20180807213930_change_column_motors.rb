class ChangeColumnMotors < ActiveRecord::Migration[5.1]
  def change
    change_column :motors, :kw, :float
  end
end
