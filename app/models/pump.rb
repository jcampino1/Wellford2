class Pump < ApplicationRecord
	has_many :tests, dependent: :destroy

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

  def self.calcular_eficiencia(caudal, coeficientes_eficiencia, diametros, diametro_final)
    """
    Entrega la eficiencia aproximada de una bomba en un punto dado (Q, H)
    """
    eficiencia1 = coeficientes_eficiencia[1][0].to_f + coeficientes_eficiencia[1][1].to_f*caudal + coeficientes_eficiencia[1][2].to_f*caudal*caudal
    eficiencia2 = coeficientes_eficiencia[0][0].to_f + coeficientes_eficiencia[0][1].to_f*caudal + coeficientes_eficiencia[0][2].to_f*caudal*caudal
    diam1 = diametros[1].to_f
    diam2 = diametros[0].to_f
    pendiente = (eficiencia2 - eficiencia1)/(diam2 - diam1)
    return eficiencia1 + pendiente*(diametro_final - diam1)
  end

  def self.diametro_final(curva_h, rodete_max, caudal, altura)
    altura_rodete_max = curva_h[0].to_f + curva_h[1].to_f*caudal + curva_h[2].to_f*caudal*caudal
    razon = altura**2/altura_rodete_max**2
    return razon*rodete_max

  end



  def self.lista_a_numero(lista)
    nueva_lista = []
    lista.each do |d|
      nueva_lista.push(d.to_f)
    end
    return nueva_lista
  end

  def self.crear_curva(curva, diametro_curva, nuevo_diametro)
    """
    Funcion que crea una nueva curva a partir de otra curva y los diametros
    de los rodetes por semejanza hidraulica
    """
    nueva_curva = []
    curva.each do |punto|
      nueva_altura = ((nuevo_diametro.to_f*punto[1].to_f*punto[1].to_f)/diametro_curva.to_f)**0.5
      nuevo_punto = [punto[0], nueva_altura]
      nueva_curva.push(nuevo_punto)
    end
    return Test.regression(nueva_curva, 2)
  end



end
