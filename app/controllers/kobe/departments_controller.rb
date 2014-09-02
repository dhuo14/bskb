# -*- encoding : utf-8 -*-
class Kobe::DepartmentsController < KobeController
  # layout false

  def index
  end

  def new
      @obj = Department.new
  end

  def create
    render :text => params
  end

  def update
  end

  def edit
    @obj = Department.find(params[:id])
  end

  def show
    @obj = Department.find(1)
  end

end
