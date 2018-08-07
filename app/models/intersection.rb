
class Intersection < ApplicationRecord

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      if row[1].to_f > 2000.to_f
        motor_id = Motor.all.where("rpm > 2000").where(hp: row[2]).first.id
        pump_id = Pump.all.where(bomba: row[0], rpm: 2900).first.id
      else
        pump_id = Pump.all.where(bomba: row[0], rpm: 1450).first.id
        motor_id = Motor.all.where("rpm < 2000").where(hp: row[2]).first.id
      end
      Intersection.create!(pump_id: pump_id, motor_id: motor_id,
        base: row[3], ancho_b1: row[4], largo_l1: row[5], hs: row[6],
        hd: row[7], a: row[8], peso: row[9])
      pump = Pump.find(pump_id)
      motor = Motor.find(motor_id)
      pump.posibles_hp.push(motor.hp.to_s)
      pump.posibles_kw.push(motor.kw.to_s)
      pump.posibles_motores.push(motor_id.to_s)
      pump.save
    end
  end
end
