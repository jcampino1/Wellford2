
class Motor < ApplicationRecord

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Motor.create!(kw: row[0], hp: row[1], frame: row[2], rpm: row[17],
        rod_delantero: row[12], rod_trasero: row[13], machon_omega: row[18],
        machon_dentado: row[19])
    end
  end
end
