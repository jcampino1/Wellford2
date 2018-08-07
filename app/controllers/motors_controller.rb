class MotorsController < ApplicationController

  def import
    Motor.import(params[:file])
    redirect_to root_url, notice: "Motor(es) importado(s)"
  end

  def new
  end

end

