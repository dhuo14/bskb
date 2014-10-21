# -*- encoding : utf-8 -*-
class Kobe::UsersController < KobeController

  before_action :get_user, :only => [:edit, :show, :update, :profile]
  layout :false, :only => [ :show, :edit ]


  def edit
  end

  def show
  end

  def profile
  end

  
  def impower
  end

  def reset_password
  end

  def update()
    if update_and_write_logs(@user)
      tips_get("更新用户信息成功。")
      redirect_to kobe_departments_path(id: @user.department.id)
    else
      flash_get(@user.errors.full_messages)
      redirect_back_or
    end
  end

  private  

  def get_user
    params[:id] ||= current_user.id
    @user = User.find(params[:id])
  end
end
