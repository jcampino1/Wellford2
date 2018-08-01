
class Pump < ApplicationRecord

	has_many :tests, dependent: :destroy

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Pump.create!(bomba: row[0], rpm: row[1], succion: row[2], rodete_min: 0,
                   descarga: row[3], motor_hp: row[4], frame: row[5],
                   base: row[6], machon_omega: row[7], machon_dentado: row[8],
                   rodete_max: row[11], anillo_delantero: row[12],
                   anillo_trasero: row[13], delantero_motor: row[14],
                   trasero_motor: row[15], delantero_bomba: row[16],
                   trasero_bomba: row[17], caudal_minimo: row[18],
                   ancho_b1: row[21], largo_l1: row[22], hs: row[29],
                   hd: row[30], a: row[31], peso_motobomba: row[32],
                   acople_machon: row[33], acople_motor: row[34])
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
    a = curva_h[0].to_f
    b = curva_h[1].to_f*caudal*rodete_max
    c = (curva_h[2].to_f*(caudal**2) - altura)*(rodete_max**2)
    raiz = ((b**2) - (4*a*c))**0.5
    return (-b + raiz)/(2*a)
    #altura_rodete_max = curva_h[0].to_f + curva_h[1].to_f*caudal + curva_h[2].to_f*caudal*caudal
    #razon = altura/altura_rodete_max
    #r_cuadrado = razon*(rodete_max**2)
    #return r_cuadrado**0.5
  end

  def self.diametro_final2(curva_arriba, curva_abajo, d_arriba, d_abajo, caudal, altura)
    h1 = curva_arriba[0].to_f + curva_arriba[1].to_f*caudal + curva_arriba[2].to_f*caudal*caudal
    h2 = curva_abajo[0].to_f + curva_abajo[1].to_f*caudal + curva_abajo[2].to_f*caudal*caudal
    pendiente = (d_arriba - d_abajo)/(h1 - h2)
    return d_abajo + pendiente*(altura - h2)
  end

  def self.buscar_entremedio(pump, caudal, altura)
    lista_alturas = []
    lista_diametros = []
    pump.valid_tests.each do |indice|
      test = pump.tests.find(indice.to_f)
      if test.diametro_rodete != pump.rodete_max and test.diametro_rodete != pump.rodete_min
        altura = test.coefficients_h[0].to_f + test.coefficients_h[1].to_f*caudal + test.coefficients_h[2].to_f*caudal*caudal
        lista_alturas.push(altura)
        lista_diametros.push(test.diametro_rodete)
      end
    end
    altura_max = pump.curva_rodete_max[0][0].to_f + pump.curva_rodete_max[0][1].to_f*caudal + pump.curva_rodete_max[0][2].to_f*caudal*caudal
    lista_alturas.push(altura_max)
    lista_diametros.push(pump.rodete_max)
    altura_min = pump.curva_rodete_min[0][0].to_f + pump.curva_rodete_min[0][1].to_f*caudal + pump.curva_rodete_min[0][2].to_f*caudal*caudal
    lista_alturas.push(altura_min)
    lista_alturas.push(pump.rodete_min)
    return lista_alturas
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
      razon_diametros = (nuevo_diametro.to_f/diametro_curva.to_f)**2
      nueva_altura = punto[1].to_f*razon_diametros
      nuevo_caudal = (punto[0].to_f*nuevo_diametro)/diametro_curva
      #nueva_altura = ((nuevo_diametro.to_f*punto[1].to_f*punto[1].to_f)/diametro_curva.to_f)**0.5
      nuevo_punto = [nuevo_caudal, nueva_altura]
      nueva_curva.push(nuevo_punto)
    end
    #return Test.regression(nueva_curva, 2)
    return nueva_curva
  end

  def self.eficiencia_100(curva)
    nueva_curva = []
    curva.each do |punto|
      nuevo_punto = [punto[0].to_f, (punto[1].to_f)*100]
      nueva_curva.push(nuevo_punto)
    end
    return nueva_curva
  end

end
