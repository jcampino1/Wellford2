
class Motor < ApplicationRecord

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Motor.create!(kw: row[0], hp: row[1], rpm: row[17],
        rod_delantero: row[12], rod_trasero: row[13])
    end
  end
end
