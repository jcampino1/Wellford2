class TestsController < ApplicationController
	before_action :set_pump

	def create
		#1. Aca tenemos que hacer la primera fase de analisis
		#2. Despues eventualmente crear la prueba definitiva (con el build)
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

