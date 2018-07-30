class AddListOfValidTests < ActiveRecord::Migration[5.1]
  def change
  	add_column :pumps, :valid_tests, :string, array: true, default: []
  end
end
