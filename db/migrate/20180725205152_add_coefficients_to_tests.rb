class AddCoefficientsToTests < ActiveRecord::Migration[5.1]
  def change
  	add_column :tests, :coefficients_h, :string, array: true, default: []
  	add_column :tests, :coefficients_e, :string, array: true, default: []
  	add_column :tests, :coefficients_p, :string, array: true, default: []
  	add_column :tests, :xmaximo, :float
  end
end
