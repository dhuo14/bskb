# -*- encoding : utf-8 -*-
class Kobe::UsersController < KobeController

  before_action :get_user, :only => [:edit, :show, :update, :reset_password, :update_password, :show_logs, :freeze, :save_freeze]
  layout :false, :only => [:show, :edit, :reset_password, :show_logs]


  def edit
    @myform = SingleForm.new(User.xml, @user, { form_id: "user_form", action: kobe_user_path(@user), method: "patch" })
  end

  def show
  end

  def reset_password
  end

  def show_logs
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

  def update_password
    if @user.update(params.require(:user).permit(:password, :password_confirmation))
      write_logs(@user,"重置密码",'重置密码成功')
      tips_get("重置密码成功。")
      redirect_to kobe_departments_path(id: @user.department.id)
    else
      flash_get(@user.errors.full_messages)
      redirect_back_or
    end
  end

  # 冻结
  def freeze
    render partial: '/shared/dialog/opt_liyou', locals: {form_id: 'freeze_user_form', action: save_freeze_kobe_user_path(@user)}
  end

  def save_freeze
    logs = prepare_logs_content(@user,"冻结用户",params[:opt_liyou])
    if @user.change_status_and_write_logs("冻结",logs)
      tips_get("冻结用户成功。")
    else
      flash_get(@user.errors.full_messages)
    end
    redirect_to kobe_departments_path(id: @user.department.id)
  end

  private  

  def get_user
    params[:id] ||= current_user.id
    @user = User.find(params[:id])
  end
end
