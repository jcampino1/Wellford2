
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

  def import_motor
    Motor.import_motor(params[:file])
    redirect_to root_url, notice: "Motor(es) importado(s)"
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
      pump = @pump.tests.find(d.to_f)
      # Aqui en volada no vale la pena meter la curva e y p
      @tests_definitivos.push([pump.diametro_rodete,
       pump.coefficients_h, pump.coefficients_e,
        pump.coefficients_p, pump.xmaximo, pump.current_h])
    end
    @lista_diametros = []
    @lista_maximos = []
    @tests_definitivos.each do |test|
      @lista_diametros.push(test[0])
      @lista_maximos.push(test[4])
    end

    @pump.curva_rodete_max.clear
    @pump.points_max.clear
    @pump.curva_rodete_min.clear
    @pump.points_min.clear

    if @lista_diametros.exclude?(@pump.rodete_max)
      indice = @lista_diametros.index(@lista_diametros.max)
      @nueva_curva_rodete_max = Pump.crear_curva(@tests_definitivos[indice][5],
        @tests_definitivos[indice][0], @pump.rodete_max)
      @pump.curva_rodete_max.push(Test.regression(@nueva_curva_rodete_max, 2))
      @pump.points_max.push(@nueva_curva_rodete_max)

    else
      @indicex = @lista_diametros.index(@pump.rodete_max)
      @pump.curva_rodete_max.push(@tests_definitivos[@indicex][1])
      @nueva_curva_rodete_max = Test.pasar_a_numero(@tests_definitivos[@indicex][5])
      @pump.points_max.push(@tests_definitivos[@indicex][5])

    end


    if @lista_diametros.exclude?(@pump.rodete_min)
      @indice = @lista_diametros.index(@lista_diametros.min)
      @nueva_curva_rodete_min = Pump.crear_curva(@tests_definitivos[@indice][5],
        @tests_definitivos[@indice][0], @pump.rodete_min)
      @pump.curva_rodete_min.push(Test.regression(@nueva_curva_rodete_min, 2))
      @pump.points_min.push(@nueva_curva_rodete_min)
    else
      indice = @lista_diametros.index(@pump.rodete_min)
      @pump.curva_rodete_min.push(@tests_definitivos[indice][1])
      @nueva_curva_rodete_min = Test.pasar_a_numero(@tests_definitivos[indice][5])
      @pump.points_min.push(@tests_definitivos[indice][5])
    end

    @pump.x_maximos.clear
    @pump.x_maximos.push(@lista_maximos.max.to_f)

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

  def detalle
    @pump = Pump.find(params[:pump_id])
    @caudal = params[:caudal].to_f
    @altura = params[:altura].to_f
    @eficiencia = params[:eficiencia].to_f
    @diametro_final = params[:diametro_final].to_f
    @diametro2 = params[:diametro2].to_f
    @curvas_definitivas = []
    @curvas_eficiencias = []

    @pump.valid_tests.each do |d|
      test = @pump.tests.find(d.to_f)
      if test.diametro_rodete != @pump.rodete_max and test.diametro_rodete != @pump.rodete_min
        @curvas_definitivas.push([Test.pasar_a_numero(test.current_h), test.diametro_rodete])
      end
      @curvas_eficiencias.push([Test.pasar_a_numero(Pump.eficiencia_100(test.current_e)), test.diametro_rodete])
    end
    # Nos va a faltar el pseudo-rodete max y pseudo-rodete_min
    @curvas_definitivas.push([Test.pasar_a_numero(@pump.points_max[0]), @pump.rodete_max])
    @curvas_definitivas.push([Test.pasar_a_numero(@pump.points_min[0]), @pump.rodete_min])
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
