class Pump < ApplicationRecord
	has_many :tests

	validates :nombre, presence: true
	validates :rpm, presence: true
	validates :rodete_max, presence: true
	validates :rodete_min, presence: true

  def self.import(file)
    """
    Crea las bombas a partir de la info del csv
    """
    CSV.foreach(file.path, headers: :true) do |row|
      Pump.create!(row.to_hash)
    end
  end

  def self.valida(pump, caudal, altura)
    """
    Analiza si el punto (Q, H) esta dentro del area factible de cada bomba
    """

    # Si la bomba aun no esta definida
    if pump.curva_rodete_max.length == 0
      return false
    end

    # Si el caudal es mayor que el Q_maximo factible para esa bomba
    if caudal > pump.x_maximos.max.to_f
      return false
    end
    
    # Vemos que este bajo la curva a rodete max
    if pump.curva_rodete_max[0][0].to_f + pump.curva_rodete_max[0][1].to_f*caudal + 
      pump.curva_rodete_max[0][2].to_f*caudal*caudal < altura
      return false
    end

    # Vemos que este sobre la curva de rodete min
    if pump.curva_rodete_min[0][0].to_f + pump.curva_rodete_min[0][1].to_f*caudal + 
      pump.curva_rodete_min[0][2].to_f*caudal*caudal > altura
      return false
    end
    return true

  end


  def self.lista_a_numero(lista)
    nueva_lista = []
    lista.each do |d|
      nueva_lista.push(d.to_f)
    end
    return nueva_lista
  end



end
