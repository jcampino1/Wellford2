
class Pump < ApplicationRecord

	has_many :tests, dependent: :destroy

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      pump = Pump.find_by(bomba: row[0], rpm: row[1]) || Pump.create!(
        bomba: row[0], rpm: row[1], frame: row[5], base: row[6],
        ancho_b1: row[21], largo_l1: row[22], hs: row[29], hd: row[30], a: row[31])
      pump.posibles_hp.push(row[4].to_s)
      pump.peso.push(row[32].to_s)
      pump.save
    end
    Pump.all.each do |pump|
      if pump.posibles_hp.length > pump.posibles_kw.length
        if pump.rpm > 2000
          Motor.all.where("rpm > 2000").each do |motor|
            if pump.posibles_hp.include? motor.hp.to_s
              pump.posibles_kw.push(motor.kw.to_s)
              pump.posibles_motores.push(motor.id.to_s)
              pump.save
            end
          end
        else
          Motor.all.where("rpm < 2000").each do |motor|
            if pump.posibles_hp.include? motor.hp.to_s
              pump.posibles_kw.push(motor.kw.to_s)
              pump.posibles_motores.push(motor.id.to_s)
              pump.save
            end
          end
        end
      end
    end
  end

  def self.valida(pump, caudal, altura)
    """
    Analiza si el punto (Q, H) esta dentro del area factible de cada bomba
    Falta ver el tema de los x maximos
    """

    # Si la bomba aun no esta definida
    if pump.curva_rodete_max.length == 0
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

    if self.limite_de_la_derecha(pump.x_maximos[0], caudal, altura)
      return false
    end

    # Si pasa todos los filtros retornamos true
    return true

  end

  def self.limite_de_la_derecha(lista_maximos, q, h)
    """
    Funcion que ve si el punto pedido cae a la izquierda de las rectas
    generadas por lo puntos maximos de cada curva hidraulica
    """
    caudales_factibles_maximos = []
    lista_maximos.each do |punto|
      caudales_factibles_maximos.push(punto[0].to_f)
    end
    return q > caudales_factibles_maximos.min
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

  #def self.calcular_eficiencia2(caudal, )

  def self.diametro_final1(curva_h, rodete_max, caudal, altura)
    """
    Determina el diametro final mediante formula deducida por Enrique
    y Victoria a partir de semejanza hidraulica.
    """

    a = curva_h[0].to_f
    b = curva_h[1].to_f*caudal*rodete_max
    c = (curva_h[2].to_f*(caudal**2) - altura)*(rodete_max**2)
    raiz = ((b**2) - (4*a*c))**0.5
    return (-b + raiz)/(2*a)
  end

  def self.diametro_final(pump, caudal, altura)
    lista_alturas = []
    lista_indices = []
    altura_max = pump.curva_rodete_max[0][0].to_f + pump.curva_rodete_max[0][1].to_f*caudal + pump.curva_rodete_max[0][2].to_f*caudal*caudal
    altura_min = pump.curva_rodete_min[0][0].to_f + pump.curva_rodete_min[0][1].to_f*caudal + pump.curva_rodete_min[0][2].to_f*caudal*caudal
    lista_alturas.push(Pump.valor_absoluto(altura_max - altura))
    lista_alturas.push(Pump.valor_absoluto(altura - altura_min))
    pump.valid_tests.each do |indice|
      test = pump.tests.find(indice.to_f)
      if test.diametro_rodete != pump.rodete_max and test.diametro_rodete != pump.rodete_min
        altura_calculada = test.coefficients_h[0].to_f + test.coefficients_h[1].to_f*caudal + test.coefficients_h[2].to_f*caudal*caudal
        lista_alturas.push(Pump.valor_absoluto(altura - altura_calculada))
        lista_indices.push(indice)
      end
    end
    #return lista_alturas.min
    indice = lista_alturas.index(lista_alturas.min)
    if indice == 0
      return self.diametro_final1(pump.curva_rodete_max[0], pump.rodete_max, caudal, altura), Test.pasar_a_numero(pump.points_max[0]), pump.rodete_max
    elsif indice == 1
      return self.diametro_final1(pump.curva_rodete_min[0], pump.rodete_min, caudal, altura), Test.pasar_a_numero(pump.points_min[0]), pump.rodete_min
    else
      test = pump.tests.find(lista_indices[indice - 2])
      return self.diametro_final1(test.coefficients_h, test.diametro_rodete, caudal, altura), Test.pasar_a_numero(test.current_h), test.diametro_rodete
    end


  end

  def self.valor_absoluto(numero)
    if numero >= 0
      return numero
    else
      return -numero
    end
  end

  def self.diametro_final2(curva_arriba, curva_abajo, d_arriba, d_abajo, caudal, altura)
    """
    Determinacion del diametro a partir de interpolacion lineal entre
    rodete max y rodete min
    """
    h1 = curva_arriba[0].to_f + curva_arriba[1].to_f*caudal + curva_arriba[2].to_f*caudal*caudal
    h2 = curva_abajo[0].to_f + curva_abajo[1].to_f*caudal + curva_abajo[2].to_f*caudal*caudal
    pendiente = (d_arriba - d_abajo)/(h1 - h2)
    return d_abajo + pendiente*(altura - h2)
  end

  def self.buscar_entremedio(pump, caudal, altura)
    """
    No presenta utilidad hasta ahora
    """

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
    """
    Para pasar una lista solo de numeros (no puntos) a valores numericos
    """
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
    """
    Se usa para pasar las eficiencias a porcentaje.
    Recibe una lista de puntos y entrega una nueva.
    """
    nueva_curva = []
    curva.each do |punto|
      nuevo_punto = [punto[0].to_f, (punto[1].to_f)*100]
      nueva_curva.push(nuevo_punto)
    end
    return nueva_curva
  end

  def self.generar_curva_e(caudal_max, curva_abajo, curva_arriba, diam_abajo, diam_arriba, diam_final)
    """
    Genera una curva hidraulica a partir de otra mediante semejanza hidraulica.
    """
    curva = []
    lista_caud = []
    unit = caudal_max/10
    n = 1
    while n < 11
      lista_caud.push(unit*n)
      n = n+1
    end
    #curva.push([0, 0])
    lista_caud.each do |caudal|
      e1 = curva_abajo[0] + curva_abajo[1]*caudal + curva_abajo[2]*caudal*caudal
      e2 = curva_arriba[0] + curva_arriba[1]*caudal + curva_arriba[2]*caudal*caudal
      pendiente = (e2 - e1)/(diam_arriba - diam_abajo)
      efi = e1 + pendiente*(diam_final - diam_abajo)
      curva.push([caudal, efi])
    end
    return curva
  end

  def self.generar_curva_p(curva_e, coeff_h)
    """
    Genera la curva de potencias a partir de los valores de la eficiencia, caudal
    y altura obtenidos anteriormente
    """
    curva = []
    curva_e.each do |punto|
      altura = coeff_h[0] + coeff_h[1]*punto[0] + coeff_h[2]*punto[0]*punto[0]
      denom = (punto[1]/100)*101.9464
      curva.push([punto[0], (punto[0]*altura)/denom])
    end
    return curva
  end

  def self.pasar_a_curvah(lista)
    curva = []
    metidos = 0
    while metidos < lista.length
      punto = [lista[metidos][0].to_f, lista[metidos+1][0].to_f]
      curva.push(punto)
      metidos = metidos + 2
    end
    return curva
  end

  def self.potencia_maxima(curva_potencia)
    lista_potencias = []
    curva_potencia.each do |punto|
      lista_potencias.push(punto[1])
    end
    return lista_potencias.max
  end

end

