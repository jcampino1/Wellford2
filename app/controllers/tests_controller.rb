class TestsController < ApplicationController
	before_action :set_pump

	def create

	# Creamos la prueba de bombeo sin nada todavia para ser analizada.
	@test = @pump.tests.build(test_params)
    @test.pump = @pump
    @test.save
    @file = file_params
    @caudales, @alturas, @eficiencias, @potencias = abrir_archivo(params[:file])



    # Mandamos a fase de analisis.
	redirect_to pump_test_analisis_path(@pump, @test)
	end

	def analisis
		@test = @pump.tests.find(params[:pump_id])
		#@caudales, @alturas, @eficiencias, @potencias = abrir_archivo(params[:file])
		@caudales = caud
		@alturas = altu
		@eficiencias = efi
		@potencias = pot
	end

	def new
		@test = @pump.tests.build
	end

	def sacar_punto
		@test = @pump.tests.find(params[:id])

	end

	def show
		@test = @pump.tests.find(params[:id])
		if @test.curva_h[0].is_a?(String)
			a = @test.curva_h[0]
			a.gsub!(/["\""]/, '')
			a.delete! "[" "]"
			@test.curva_h = a.split(", ").each_slice(2).to_a
		end
	end

	def edit
		@test = @pump.tests.find(params[:id])
	end

	def update
		@test = @pump.tests.find(params[:id])
		respond_to do |format|
      if @test.update(test_params)
        format.html { redirect_to [@pump, @test], notice: 'Test was successfully updated.' }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
	end

	def cortada
		@test = @pump.tests.find(params[:test_id])
		if @test.current_h == @test.curva_h[0..@test.curva_h.length - params[:n].to_i]
			@test.current_h = @test.current_h[0..@test.current_h.length - 1]
		else
			@test.current_h = @test.curva_h[0..@test.curva_h.length - params[:n].to_i]
		end
		@test.save
	end




	# Funciones auxiliares

	def set_pump
		@pump = Pump.find(params[:pump_id])
	end

	def test_params
		params.require(:test).permit(:pump_id, :diametro_rodete,
																 :curva_e, :curva_p, curva_h:[])
	end

	def file_params
		params.require(:test).permit(:file)
	end

	def abrir_archivo archivo
		caud = []
		altu = []
		efi = []
		pot = []
		if archivo.respond_to?(:read)
			csv = file.read
		else
			CSV.foreach(archivo.path) do |linea|
				caud.push(linea[0])
				altu.push(linea[1])
				efi.push(linea[2])
				pot.push(linea[3])
			end
			return caud, altu, efi, pot
		end
	end

	def import
	  diametro, curva_h, curva_e, curva_p = Test.import(@pump, params[:file])
	  @test = @pump.tests.build({diametro_rodete: diametro,
	  													 curva_h: curva_h,
	  													 curva_e: curva_e,
	  													 curva_p: curva_p})
	  @test.pump = @pump
	  @test.save

	  redirect_to pump_test_path(@pump, @test)
	end

	private

	def h_param
		eval(param[:curva_h])
	end
end

