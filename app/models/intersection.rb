
class Intersection < ApplicationRecord

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      pump_id = Pump.all.where(bomba: row[0], rpm: row[1]).first.id
      if row[1].to_f > 2000.to_f
        motor_id = Motor.all.where("rpm > 2000").where(hp: row[4]).first.id
      else
        motor_id = Motor.all.where("rpm < 2000").where(hp: row[4]).first.id
      end
      Intersection.create!(succion: row[2], descarga: row[3], pump_id: pump_id,
        motor_id: motor_id, rodete_max: row[11], machon_omega: row[7],
        machon_dentado: row[8], anillo_delantero: row[12],
        anillo_trasero: row[13], bomba_delantero: row[16],
        bomba_trasero: row[17], caudal_minimo: row[18])
    end
  end
end
