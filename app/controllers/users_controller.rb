# -*- encoding : utf-8 -*-
class UsersController < JamesController

  skip_before_action :verify_authenticity_token, :only => [:valid_dep_name, :valid_user_login]

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
      if user.department.get_tips.blank?
        redirect_to root_path
      else
        redirect_to kobe_departments_path
      end
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
      redirect_to kobe_departments_path
    else
      redirect_to sign_up_users_path
    end
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

end
