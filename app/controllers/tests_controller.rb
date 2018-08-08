class TestsController < ApplicationController
	before_action :set_pump

	def new
		@test = @pump.tests.build
	end

	def destroy
		@test = @pump.tests.find(params[:test_id])
		if @pump.valid_tests.include?(@test.id)
			@pump.valid_tests.delete(@test.id)
		end
		@test.destroy
		redirect_to root_url
	end

	def show
		@test = @pump.tests.find(params[:id])
		@puntos = Test.pasar_a_numero(@test.curva_h)
		@puntos2 = Pump.eficiencia_100(Test.pasar_a_numero(@test.curva_e))
		@test.current_h = @test.curva_h
		@test.current_e = @test.curva_e
		@test.save
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
		@test.current_h = @test.curva_h[0..@test.curva_h.length - params[:n].to_i - 1]
		@test.current_e = @test.curva_e[0..@test.curva_e.length - params[:n].to_i - 1]
		@puntos = Test.pasar_a_numero(@test.current_h)
		@puntos2 = Pump.eficiencia_100(Test.pasar_a_numero(@test.current_e))
		@test.save
	end

	def guardar
		@test = @pump.tests.find(params[:test_id])
		@test.current_h = @test.curva_h[0..@test.curva_h.length - params[:n].to_i - 1]
		@test.current_e = @test.curva_e[0..@test.curva_e.length - params[:n].to_i - 1]
		@test.curva_h = []
		@test.curva_e = []
		@test.coefficients_h = Test.regression(Test.pasar_a_numero(@test.current_h), 2)
		@test.coefficients_e = Test.regression(Test.pasar_a_numero(@test.current_e), 2)
		@test.xmaximos = @test.current_h[-1]
		@test.save
		redirect_to pump_path(@pump)
	end
	

	def guardar_igual
		@test = @pump.tests.find(params[:test_id])
		@test.current_h = @test.curva_h
		@test.current_e = @test.curva_e
		@test.curva_h = []
		@test.curva_e = []
		@test.coefficients_h = Test.regression(Test.pasar_a_numero(@test.current_h), 2)
		@test.coefficients_e = Test.regression(Test.pasar_a_numero(@test.current_e), 2)
		@test.xmaximos = @test.current_h[-1]
		@test.save
		redirect_to pump_path(@pump)
	end

	def sacar_valida
		@test = @pump.tests.find(params[:test_id])
		@pump.valid_tests.delete(@test.id.to_s)
		@pump.save
		redirect_to pump_path(@pump)
	end

	def entrar_valida
		@test = @pump.tests.find(params[:test_id])
		@pump.valid_tests.push(@test.id)
		@pump.save
		redirect_to pump_path(@pump)
	end




	# Funciones auxiliares

	def set_pump
		@pump = Pump.find(params[:pump_id])
	end

	def test_params
		params.require(:test).permit(:pump_id, :diametro_rodete,
																 :curva_e, curva_h:[])
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
	  nombre, numero_pedido, diametro, curva_h, curva_e = Test.import(@pump, params[:file])
	  @test = @pump.tests.build({nombre: nombre, 
	  										numero_pedido: numero_pedido, 
	  											diametro_rodete: diametro,
	  													 curva_h: curva_h,
	  													 curva_e: curva_e,})
	  @test.pump = @pump
	  @test.save

	  redirect_to pump_test_path(@pump, @test)
	end

end

