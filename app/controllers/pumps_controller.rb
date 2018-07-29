class PumpsController < ApplicationController
  before_action :set_pump, only: [:show, :edit, :update, :destroy]
  #skip_before_action :buscar

  # GET /pumps
  # GET /pumps.json
  def index
    @pumps = Pump.all
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
    redirect_to root_url, notice: "Bomba importada"
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

    @pump.valid_tests.each do |d|
      pump = @pump.tests.find(d.to_f)
      # Aqui en volada no vale la pena meter la curva e y p
      @tests_definitivos.push([pump.diametro_rodete,
       pump.coefficients_h, pump.coefficients_e,
        pump.coefficients_p, pump.xmaximo])
    end
    lista_diametros = []
    lista_maximos = []
    @tests_definitivos.each do |test|
      lista_diametros.push(test[0])
      lista_maximos.push(test[4])
    end
    if lista_diametros.exclude?(@pump.rodete_max)
      @cierto = 1
      @pumps.curva_rodete_max = "hola"
      # Si no lo tiene, crearlo y meterlo a la lista de informacion
    else
      @indicex = lista_diametros.index(@pump.rodete_max)
      @pump.curva_rodete_max.clear
      @pump.curva_rodete_max.push(@tests_definitivos[@indicex][1])
      #@pump.curva_rodete_max = [Pump.lista_a_numero(@tests_definitivos[indice][1]),
      # @tests_definitivos[indice][4].to_f]

    end

    if lista_diametros.exclude?(@pump.rodete_min)
      @cierto = 2
      indice = lista_diametros.index(lista_diametros.min)
      @pump.curva_rodete_min.clear
      @pump.curva_rodete_min.push(@tests_definitivos[indice][1])
      #@pump.curva_rodete_min = [Pump.lista_a_numero(@tests_definitivos[indice][1]),
      # @tests_definitivos[indice][4].to_f]
      # Si no lo tiene, crearlo y meterlo a la lista de informacion
    else
      indice = lista_diametros.index(@pump.rodete_min)
      @pump.curva_rodete_min.clear
      @pump.curva_rodete_min.push(@tests_definitivos[indice][1])
      #@pump.curva_rodete_min = [Pump.lista_a_numero(@tests_definitivos[indice][1]),
      # @tests_definitivos[indice][4].to_f]
    end
    @pump.x_maximos.clear
    @pump.x_maximos.push(lista_maximos.max.to_f)
    @pump.save



    #redirect_to pumps_path
  end

  def detalle
    @pump = Pump.find(params[:pump_id])
    @caudal = params[:caudal].to_f
    @altura = params[:altura].to_f
    @curvas_definitivas = []

    @pump.valid_tests.each do |d|
      test = @pump.tests.find(d.to_f)
      @curvas_definitivas.push([Test.pasar_a_numero(test.current_h), test.diametro_rodete])
    end
    # Nos va a faltar el pseudo-rodete max y pseudo-rodete_min
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pump
      @pump = Pump.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pump_params
      params.require(:pump).permit(:nombre, :rpm, :rodete_max, :rodete_min)
    end
end
