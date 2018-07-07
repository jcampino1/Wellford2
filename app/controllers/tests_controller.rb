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

	def set_pump
		@pump = Pump.find(params[:pump_id])
	end

	def test_params
		params.require(:test).permit(:pump_id, :diametro_rodete)
	end
end

