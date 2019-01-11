
class Pump < ApplicationRecord

	has_many :tests, dependent: :destroy

  def self.exportar_datos_excel(datos, curva_h, curva_e, curva_p)
    lista_unida = self.unir_listas_excel(curva_h, curva_e, curva_p)
    CSV.generate({:col_sep => "\t"}) do |csv|
      csv << ['Bomba', 'RPM','Rodete Maximo', 'Caudal', 'Altura', 'Eficiencia', 'Pot maxima',
       'Pot consumo', 'Diametro rodete', 'Caudal maximo', 'Altura minima', 'Altura maxima']
      

      csv << datos
      csv << ["Caudal", "Altura", "Caudal", "Eficiencia", "Caudal", "Potencia"]
      
      lista_unida.each do |punto|
        csv << punto
      end
    end
    #CSV.open("myfile.xls", "w", {:col_sep => "\t"})  do |archivo|
    #  archivo << ["1", "2"]
    #end
  end

  def self.unir_listas_excel(curva_h, curva_e, curva_p)
    lista = []
    contador = 0
    while curva_h.length > contador or curva_e.length > contador or curva_p.length > contador
      if contador >= curva_h.length
        a = 0
        b = 0
      else 
        a = curva_h[contador][0]
        b = curva_h[contador][1]
      end
      if contador >= curva_e.length
        c = 0
        d = 0
      else 
        c = curva_e[contador][0]
        d = curva_e[contador][1]
      end
      if contador >= curva_p.length
        e = 0
        f = 0
      else 
        e = curva_p[contador][0]
        f = curva_p[contador][1]
      end


      lista.push([a.to_s.gsub('.', ','), b.to_s.gsub('.', ','), c.to_s.gsub('.', ','), 
        d.to_s.gsub('.', ','), e.to_s.gsub('.', ','), f.to_s.gsub('.', ',')])
      contador += 1
      #lista.push([curva_h[0][0], curva_h[0][1], curva_e[0][0], curva_e[0][1], curva_p[0][0], curva_p[0][1]])
    end
    return lista

  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Pump.create!(
        bomba: row[0], succion: row[1], descarga: row[2], rodete_max: row[5],
        rodete_min: row[6], caudal_minimo_2900: row[3],
        caudal_minimo_1450: row[4], anillo_delantero: row[7],
        anillo_trasero: row[8], bomba_delantero: row[9],
        bomba_trasero: row[10], rpm: 2900)
      Pump.create!(
        bomba: row[0], succion: row[1], descarga: row[2], rodete_max: row[5],
        rodete_min: row[6], caudal_minimo_2900: row[3],
        caudal_minimo_1450: row[4], anillo_delantero: row[7],
        anillo_trasero: row[8], bomba_delantero: row[9],
        bomba_trasero: row[10], rpm: 1450)
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
    Funcion que ve si el punto pedido cae a la derecha de la recta
    generadas por lo puntos maximos de la curva a rodete max y 
    la curva a rodete min
    """
    punto_rodete_max = [lista_maximos[0][0].to_f, lista_maximos[0][1].to_f]
    punto_rodete_min = [lista_maximos[1][0].to_f, lista_maximos[1][1].to_f]
    pendiente = (punto_rodete_max[0] - punto_rodete_min[0])/(punto_rodete_max[1] - punto_rodete_min[1])
    caudal_calculado = punto_rodete_min[0] + pendiente*(h - punto_rodete_min[1])

    return q > caudal_calculado
  end

  def self.calcular_eficiencia(caudal, coeficientes_eficiencia, diametros, diametro_final)
    """
    Entrega la eficiencia aproximada de una bomba en un punto dado (Q, H)
    """
    eficiencia1 = coeficientes_eficiencia[1][0].to_f + coeficientes_eficiencia[1][1].to_f*caudal + coeficientes_eficiencia[1][2].to_f*caudal*caudal + coeficientes_eficiencia[1][3].to_f*(caudal**3) + coeficientes_eficiencia[1][4].to_f*(caudal**4)

    eficiencia2 = coeficientes_eficiencia[0][0].to_f + coeficientes_eficiencia[0][1].to_f*caudal + coeficientes_eficiencia[0][2].to_f*caudal*caudal + coeficientes_eficiencia[0][3].to_f*(caudal**3) + coeficientes_eficiencia[0][4].to_f*(caudal**4)
    
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
    Genera una curva de eficiencia a partir de otras 2 mediante interpolacion lineal.
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
      e1 = curva_abajo[0] + curva_abajo[1]*caudal + curva_abajo[2]*caudal*caudal + curva_abajo[3]*(caudal**3) + curva_abajo[4]*(caudal**4)
      e2 = curva_arriba[0] + curva_arriba[1]*caudal + curva_arriba[2]*caudal*caudal + curva_arriba[3]*(caudal**3) + curva_arriba[4]*(caudal**4)
      pendiente = (e2 - e1)/(diam_arriba - diam_abajo)
      efi = e1 + pendiente*(diam_final - diam_abajo)
      curva.push([caudal, efi])
    end
    return [[0, 0]] + curva
  end

  def self.generar_curva_p(curva_e, coeff_h)
    """
    Genera la curva de potencias a partir de los valores de la eficiencia, caudal
    y altura obtenidos anteriormente
    """
    curva = []
    curva_e[1..-1].each do |punto|
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

  def self.buscar_motor(pump, pot_cons, pot_max, coef)
    pump.posibles_kw.each do |potencia|
      if potencia.to_f > pot_cons
        if (potencia.to_f)*coef > pot_max
          indice = pump.posibles_kw.index(potencia)
          return potencia, pump.posibles_hp[indice]
        end
      end
    end
    return -1, -1
  end

  def self.definitiva_masiva()
    Pump.all.each do |pump|
      if pump.valid_tests.length > 1
        Pump.configuracion_definitiva(pump.id)
      end
    end
  end

  def self.configuracion_definitiva(id)
    pump = Pump.find(id)
    atributos_tests = []
    lista_diametros = []
    lista_maximos = []

    pump.valid_tests.each do |test_id|
      test = Test.find(test_id.to_i)
      coef_eficiencia = Test.regression(Test.pasar_a_numero(test.current_e), 4)
      atributos_tests.push([test.diametro_rodete, test.coefficients_h, coef_eficiencia, test.current_h])
      lista_diametros.push(test.diametro_rodete)
    end
    pump.curva_rodete_max.clear
    pump.curva_rodete_min.clear
    # Proximamente sacar estos puntos max y min
    pump.points_max.clear
    pump.points_min.clear

    if lista_diametros.exclude?(pump.rodete_max)
      indice = lista_diametros.index(lista_diametros.max)
      nueva_curva_rodete_max = Pump.crear_curva(atributos_tests[indice][3],
        atributos_tests[indice][0], pump.rodete_max)
      pump.curva_rodete_max.push(Test.regression(nueva_curva_rodete_max, 2))
      pump.points_max.push(@nueva_curva_rodete_max)

    else
      indicex = lista_diametros.index(pump.rodete_max)
      pump.curva_rodete_max.push(atributos_tests[indicex][1])
      nueva_curva_rodete_max = Test.pasar_a_numero(atributos_tests[indicex][3])
      pump.points_max.push(atributos_tests[indicex][3])
    end

    if lista_diametros.exclude?(pump.rodete_min)
      indice = lista_diametros.index(lista_diametros.min)
      nueva_curva_rodete_min = Pump.crear_curva(atributos_tests[indice][3],
        atributos_tests[indice][0], pump.rodete_min)
      pump.curva_rodete_min.push(Test.regression(nueva_curva_rodete_min, 2))
      pump.points_min.push(nueva_curva_rodete_min)
    else
      indice = lista_diametros.index(pump.rodete_min)
      pump.curva_rodete_min.push(atributos_tests[indice][1])
      nueva_curva_rodete_min = Test.pasar_a_numero(atributos_tests[indice][3])
      pump.points_min.push(atributos_tests[indice][3])
    end

    lista_maximos.push(nueva_curva_rodete_max[-1])
    lista_maximos.push(nueva_curva_rodete_min[-1])

    pump.x_maximos.clear
    pump.x_maximos.push(lista_maximos)

    # Ahora la info de la eficiencia

    indice1 = lista_diametros.index(lista_diametros.max)
    indice2 = lista_diametros.index(lista_diametros.min)
    
    # Aca entonces calculamos la regresion y la metemos, no la guardada en 
    # cada prueba de bombeo

    pump.efficiency_info.clear
    pump.efficiency_info_diams.clear
    pump.efficiency_info.push(atributos_tests[indice1][2])
    pump.efficiency_info_diams.push(atributos_tests[indice1][0])
    pump.efficiency_info.push(atributos_tests[indice2][2])
    pump.efficiency_info_diams.push(atributos_tests[indice2][0])

    # Guardar los cambios
    pump.save

    return atributos_tests, nueva_curva_rodete_max, nueva_curva_rodete_min
  end

end

