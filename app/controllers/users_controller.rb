# -*- encoding : utf-8 -*-
class UsersController < JamesController

  skip_before_action :verify_authenticity_token, :only => [ :valid_dep_name, :valid_user_login ]
  before_action :get_step_array, :only => [:sign_up, :edit_dep, :sign_up_upload, :edit_user, :show]

  def sign_in
  end

  def sign_up
  end

  def forgot_password
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
    redirect_to sign_in_users_path
  end

  def login
    user = User.find_by(login: params[:user][:login].downcase)
    if user && user.authenticate(params[:user][:password])
      sign_in_user(user, params[:user][:remember_me] == '1')
      if user.name.blank?
        flash_get('抱歉，您的资料还未填写，请先维护您的个人信息。',"info")
      end
      redirect_to kobe_departments_path
    else
      flash_get '用户名或者密码错误!'
      redirect_to sign_in_users_path
    end
  end

  # 注册 department表和user表占位子
  def create_user_dep
    dep = Department.new(name: params[:user][:dep], parent_id: '3')
    user = User.new(params.require(:user).permit(:login, :email, :password, :password_confirmation))
    if dep.save && user.save
      user.update(department_id: dep.id)
      sign_in_user user
      write_logs(dep,"注册",'账号创建成功')
      write_logs(user,"注册",'账号创建成功')
      redirect_to edit_dep_users_path
    else
      redirect_to sign_up_users_path
    end
  end

  def edit_dep
  end

  def edit_user
  end

  def sign_up_upload

  end

  def upload
    redirect_to edit_user_users_path
  end

  def update_dep
    dep = current_user.department
    if update_and_write_logs(dep)
      tips_get("更新单位信息成功。")
      redirect_to sign_up_upload_users_path
    else
      flash_get(dep.errors.full_messages)
      redirect_back_or
    end
  end

  def update_user
    if update_and_write_logs(current_user)
      tips_get("更新用户信息成功。")
      redirect_to user_path(current_user)
    else
      flash_get(current_user.errors.full_messages)
      redirect_back_or
    end
  end

  def show
  end

  def valid_dep_name
    render :text => valid_unique_dep_name(params[:user][:dep])
  end

  def valid_user_login
    render :text => valid_unique_user_login(params[:user][:login])
  end

  private  

  def current_user=(user)
    @current_user = user
  end

  def sign_in_user(user,remember_me = false)
    remember_token = User.new_remember_token
    if remember_me
      cookies.permanent[:remember_token] = remember_token # 20年有效期
    else
      cookies[:remember_token] = remember_token # 30min 或关闭浏览器消失
    end
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user= user
  end

  def get_step_array
    @arr = ["设置登录名", "填写单位信息", "上传资质证书", "填写用户信息", "提交审核", "注册成功"]
  end
end
