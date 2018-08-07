class IntersectionsController < ApplicationController

  def import
    Intersection.import(params[:file])
    redirect_to root_url, notice: "Interseccion(es) importada(s)"
  end

  def new
  end

end

