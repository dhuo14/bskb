# -*- encoding : utf-8 -*-
class Kobe::DepartmentsController < KobeController
  before_action :get_dep, :only => [ :show, :edit, :update ]

  def index
  end

  def new
      @obj = Department.new
  end

  def create
    render :text => params
  end

  def update
    if update_and_write_logs(@dep)
      tips_get("更新单位信息成功。")
      redirect_to kobe_department_path(@dep)
    else
      flash_get(@dep.errors.full_messages)
      redirect_back_or
    end
  end

  def edit
  end

  def show
  end

  private  

    def get_dep
      @dep = Department.find(params[:id]) unless params[:id].blank? 
    end
end
