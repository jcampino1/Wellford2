class TestsController < ApplicationController
	before_action :set_pump

	def create

	# Creamos la prueba de bombeo sin nada todavia para ser analizada.	
	@test = @pump.tests.build(test_params)
    @test.pump = @pump
    @test.save


    # Mandamos a fase de analisis.
	redirect_to pump_test_analisis_path(@pump, @test)
	end

	def analisis
		@test = @pump.tests.find(params[:pump_id])
		#@caudales, @alturas, @eficiencias, @potencias = abrir_archivo(params[:file])
	end

	def new
		@test = @pump.tests.build
	end






	# Funciones auxiliares

	def set_pump
		@pump = Pump.find(params[:pump_id])
	end

	def test_params
		params.require(:test).permit(:pump_id, :diametro_rodete)
	end

	def abrir_archivo archivo
		caud = []
		altu = []
		efi = []
		pot = []
		CSV.foreach(archivo) do |linea|
			caud.push(linea[0].to_f)
			altu.push(linea[1].to_f)
			efi.push(linea[2].to_f)
			pot.push(linea[3].to_f)
		end
		return caud, altu, efi, pot
	end
end

