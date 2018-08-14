
class PumpsController < ApplicationController
  before_action :set_pump, only: [:show, :edit, :update, :destroy]
  #skip_before_action :buscar

  # GET /pumps
  # GET /pumps.json
  def index
    @q = Pump.search(params[:q])
    @pumps = @q.result
  end

  # GET /pumps/1
  # GET /pumps/1.json
  def show
    if @pump.tests.count > 0
      @tests = @pump.tests
      @puntos = Test.pasar_a_numero(@tests.first.current_h)
    else
      @puntos = [[12, 5], [1.19, 6]]
    end
  end

  # GET /pumps/new
  def new
    @pump = Pump.new
  end

  # GET /pumps/1/edit
  def edit
  end

  # POST /pumps
  # POST /pumps.json
  def create
    @pump = Pump.new(pump_params)

    respond_to do |format|
      if @pump.save
        format.html { redirect_to @pump, notice: 'Pump was successfully created.' }
        format.json { render :show, status: :created, location: @pump }
      else
        format.html { render :new }
        format.json { render json: @pump.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pumps/1
  # PATCH/PUT /pumps/1.json
  def update
    respond_to do |format|
      if @pump.update(pump_params)
        format.html { redirect_to @pump, notice: 'Pump was successfully updated.' }
        format.json { render :show, status: :ok, location: @pump }
      else
        format.html { render :edit }
        format.json { render json: @pump.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pumps/1
  # DELETE /pumps/1.json
  def destroy
    @pump.destroy
    respond_to do |format|
      format.html { redirect_to pumps_url, notice: 'Pump was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    Pump.import(params[:file])
    redirect_to root_url, notice: "Bomba(s) importada(s)"
  end



  def buscar
    @caudal = params[:caudal].to_f
    @altura = params[:altura].to_f
    @pumps = Pump.all
    @pumps_final = []
    @pumps.each do |pump|
      if Pump.valida(pump, @caudal, @altura)
        @pumps_final.push(pump)
      end
    end
  end

  def definitiva
    @pump = Pump.find(params[:pump_id])
    @tests_definitivos = []
    @nueva_curva_rodete_min = []
    @nueva_curva_rodete_max = []

    @pump.valid_tests.each do |d|
      test = @pump.tests.find(d.to_f)
      # Aqui en volada no vale la pena meter la curva e y p
      @tests_definitivos.push([test.diametro_rodete,
       test.coefficients_h, test.coefficients_e, test.xmaximos, test.current_h])
    end
    @lista_diametros = []
    @lista_maximos = []
    @tests_definitivos.each do |test|
      @lista_diametros.push(test[0])
      @lista_maximos.push(test[3])
    end

    @pump.curva_rodete_max.clear
    @pump.points_max.clear
    @pump.curva_rodete_min.clear
    @pump.points_min.clear

    if @lista_diametros.exclude?(@pump.rodete_max)
      indice = @lista_diametros.index(@lista_diametros.max)
      @nueva_curva_rodete_max = Pump.crear_curva(@tests_definitivos[indice][4],
        @tests_definitivos[indice][0], @pump.rodete_max)
      @pump.curva_rodete_max.push(Test.regression(@nueva_curva_rodete_max, 2))
      @pump.points_max.push(@nueva_curva_rodete_max)

    else
      @indicex = @lista_diametros.index(@pump.rodete_max)
      @pump.curva_rodete_max.push(@tests_definitivos[@indicex][1])
      @nueva_curva_rodete_max = Test.pasar_a_numero(@tests_definitivos[@indicex][4])
      @pump.points_max.push(@tests_definitivos[@indicex][4])

    end


    if @lista_diametros.exclude?(@pump.rodete_min)
      @indice = @lista_diametros.index(@lista_diametros.min)
      @nueva_curva_rodete_min = Pump.crear_curva(@tests_definitivos[@indice][4],
        @tests_definitivos[@indice][0], @pump.rodete_min)
      @pump.curva_rodete_min.push(Test.regression(@nueva_curva_rodete_min, 2))
      @pump.points_min.push(@nueva_curva_rodete_min)
    else
      indice = @lista_diametros.index(@pump.rodete_min)
      @pump.curva_rodete_min.push(@tests_definitivos[indice][1])
      @nueva_curva_rodete_min = Test.pasar_a_numero(@tests_definitivos[indice][4])
      @pump.points_min.push(@tests_definitivos[indice][4])
    end

    @pump.x_maximos.clear
    @pump.x_maximos.push(@lista_maximos)

    # Ahora la informacion de la eficiencia
    indice1 = @lista_diametros.index(@lista_diametros.max)
    indice2 = @lista_diametros.index(@lista_diametros.min)
    @pump.efficiency_info.clear
    @pump.efficiency_info_diams.clear
    @pump.efficiency_info.push(@tests_definitivos[indice1][2])
    @pump.efficiency_info_diams.push(@tests_definitivos[indice1][0])
    @pump.efficiency_info.push(@tests_definitivos[indice2][2])
    @pump.efficiency_info_diams.push(@tests_definitivos[indice2][0])
    @pump.save



    #redirect_to pumps_path
  end

  def buscar
    @caudal = params[:caudal].to_f
    @altura = params[:altura].to_f
    @lista_marcas = []
    @lista_polos = []
    @weg = params[:weg]
    @wellford = params[:wellford]
    @siemens = params[:siemens]
    @cg = params[:cg]
    @dos_polos = params[:dos_polos]
    @cuatro_polos = params[:cuatro_polos]

    if @weg
      @lista_marcas.push("WEG")
    end
    if @wellford
      @lista_marcas.push("Wellford")
    end
    if @siemens
      @lista_marcas.push("Siemens")
    end
    if @cg
      @lista_marcas.push("CG")
    end

    if @lista_marcas.length == 0
      @lista_marcas = ["WEG", "Wellford", "Siemens", "CG"]
    end

    if @dos_polos
      @lista_polos.push("2")
    end
    if @cuatro_polos
      @lista_polos.push("4")
    end

    if @lista_polos.length == 0 or @lista_polos.length ==2
      @pumps = Pump.all
    
    else
      if @lista_polos[0] == "2"
        @pumps = Pump.where(rpm: 2900)
      else
        @pumps = Pump.where(rpm: 1450).or(Pump.where(rpm: 1480))
      end
    end

    #@pumps = Pump.all

    @pumps_final = []
    @pumps.each do |pump|
      if Pump.valida(pump, @caudal, @altura)
        @pumps_final.push(pump)
      end
    end

  end

  def detalle
    @pump = Pump.find(params[:pump_id])
    @caudal = params[:caudal].to_f
    @altura = params[:altura].to_f
    @eficiencia = params[:eficiencia].to_f
    @diametro_final = params[:diametro_final].to_f
    @curva_a_usar = Pump.pasar_a_curvah(params[:curva_a_usar])
    @diametro_a_usar = params[:diametro_a_usar]
    @lista_marcas = params[:lista_marcas]
    @lista_polos = params[:lista_polos]
    @curvas_definitivas = []
    @curvas_eficiencias = []

    @pump.valid_tests.each do |d|
      test = @pump.tests.find(d.to_f)
      # En caso de querer mostrar todas las curvas h, descomentar las 3 stes lineas.
    #  if test.diametro_rodete != @pump.rodete_max and test.diametro_rodete != @pump.rodete_min
    #    @curvas_definitivas.push([Test.pasar_a_numero(test.current_h), test.diametro_rodete])
    #  end
      if @pump.efficiency_info_diams.include?(test.diametro_rodete.to_s)
        @curvas_eficiencias.push([Test.pasar_a_numero(Pump.eficiencia_100(test.current_e)), test.diametro_rodete])
      end
    end
    @curvas_definitivas.push([Test.pasar_a_numero(@pump.points_max[0]), " máximo (" + @pump.rodete_max.to_s + ")"])
    @curvas_definitivas.push([Test.pasar_a_numero(@pump.points_min[0]), " mínimo (" + @pump.rodete_min.to_s + ")"])
    
    # Determinacion curva hidraulica nuevo punto
    @curva = Pump.crear_curva(Test.pasar_a_numero(@curva_a_usar), @diametro_a_usar.to_f, @diametro_final)
    @caudal_max = @curva[-1][0]
    @curvas_definitivas.push([@curva, "generado " + @diametro_final.round(2).to_s])

    # Determinacion curva eficiencia
    coef_1 = Test.regression(@curvas_eficiencias[1][0], 2)
    coef_2 = Test.regression(@curvas_eficiencias[0][0], 2)
    @nueva_curva_e = Pump.generar_curva_e(@caudal_max, coef_1, coef_2, 
      @curvas_eficiencias[1][1], @curvas_eficiencias[0][1], @diametro_final)

    # En caso de querer volver a mostrar todas las curvas de eficiencia, 
    # comentar linea de abajo
    @curvas_eficiencias.clear
    @curvas_eficiencias.push([@nueva_curva_e, "generado " + @diametro_final.round(2).to_s])
    
    # Determinacion curva potencia
    @coeff_nueva_h = Test.regression(@curva, 2)
    @curva_potencia = Pump.generar_curva_p(@nueva_curva_e, @coeff_nueva_h)
    @c1 = @nueva_curva_e[4][0]
    @e1 = @nueva_curva_e[4][1]
    @h1 = @coeff_nueva_h[0] + @coeff_nueva_h[1]*@c1 + @coeff_nueva_h[2]*@c1*@c1
    @pot1 = (@c1*@h1)/(@e1*101.9464)
    
    #Coeficientes de dicha curva y potencia requerida como punto para mostrar en grafico
    curva_p = Test.regression(@curva_potencia, 2)
    @potencia_requerida = [[@caudal, curva_p[0] + curva_p[1]*@caudal + curva_p[2]*@caudal*@caudal]]
    
    #Potencia consumo y maxima
    @potencia_consumo = @potencia_requerida[0][1]
    @potencia_maxima = Pump.potencia_maxima(@curva_potencia)

    #@weg = false
    #@wellford = false
    #@cg = false
    #@siemens = false
    if @lista_marcas.include?("WEG")
      @weg = "1"
      @motor_weg, @hp_weg = Pump.buscar_motor(@pump, @potencia_consumo, @potencia_maxima, 1.15)
    end

    if @lista_marcas.include?("Wellford")
      @wellford = "1"
      @motor_wellford, @hp_wellford = Pump.buscar_motor(@pump, @potencia_consumo, @potencia_maxima, 1.05)
    end

    if @lista_marcas.include?("CG")
      @cg = "1"
      @motor_cg, @hp_cg = Pump.buscar_motor(@pump, @potencia_consumo, @potencia_maxima, 1.05)
    end

    if @lista_marcas.include?("Siemens")
      @siemens = "1"
      @motor_siemens, @hp_siemens = Pump.buscar_motor(@pump, @potencia_consumo, @potencia_maxima, 1.1)
    end

    # Para devolver los polos seleccionados
    if @lista_polos != NIL
      if @lista_polos.include?("2")
        @dos_polos = "1"
      end
      if @lista_polos.include?("4")
        @cuatro_polos = "1"
      end
    end

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pump
      @pump = Pump.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pump_params
      params.require(:pump).permit(:bomba, :rpm, :succion, :descarga, :motor_hp, :frame, :base, :machon_omega, :machon_dentado, :rodete_max, :anillo_delantero, :anillo_trasero, :delantero_motor, :trasero_motor, :delantero_bomba, :trasero_bomba, :caudal_minimo, :ancho_b1, :largo_l1, :hs, :hd, :a, :peso_motobomba, :acomple_machon, :acople_motor, :caudal, :altura, :rodete_min)
    end
end
