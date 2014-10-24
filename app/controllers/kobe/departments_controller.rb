# -*- encoding : utf-8 -*-
class Kobe::DepartmentsController < KobeController

  skip_before_action :verify_authenticity_token, :only => [:move, :valid_dep_name, :destroy]
  before_action :get_dep, :only => [:index, :show, :edit, :update, :destroy, :freeze]
  # 用于注册
  before_action :get_step_array, :only => [:sign_up_dep, :sign_up_upload, :sign_up_user, :sign_up_show]
  layout :false, :only => [:show, :edit, :new]

  def index
    
  end

  def move
    ztree_move(Department)
  end

  def ztree
    ztree_json(Department)
  end

  def new
    @dep = Department.new
    @dep.parent_id = params[:pid] unless params[:pid].blank?
  end

  def create
    dep = create_and_write_logs(Department)
    if dep
      tips_get("创建成功。")
      redirect_to kobe_departments_path(id: dep)
    else
      redirect_to root_path
    end
  end

  def update
    if update_and_write_logs(@dep)
      tips_get("更新单位信息成功。")
      redirect_to kobe_departments_path(id: @dep)
    else
      flash_get(@dep.errors.full_messages)
      redirect_back_or
    end
  end

  def edit
  end

  def show
  end

  # 删除单位
  def destroy
    if @dep.destroy
      render :text => "删除成功！"
    else
      render :text => "操作失败！"
    end
  end

  # 冻结单位
  def freeze
    logs = prepare_logs_content(@dep,"冻结单位",params[:opt_liyou])
    @dep.change_status_and_write_logs("冻结",logs)
    redirect_to kobe_departments_path(id: @dep)
  end

  # 分配人员账号
  def add_user
    user = User.new(params.require(:user).permit(:login, :password, :password_confirmation))
    if user.save
      user.update(department_id: params[:id])
      write_logs(user,"分配人员账号",'账号创建成功')
      redirect_to kobe_departments_path(id: params[:id],u_id: user.id)
    else
      redirect_back_or
    end
  end

  # 验证单位名称
  def valid_dep_name
    render :text => valid_unique_dep_name(params[:departments][:name],params[:obj_id])
  end

  # 注册 填写单位信息
  def sign_up_dep
  end

  # 注册 上传附件
  def sign_up_upload
  end

  # 注册 填写用户信息
  def sign_up_user
  end

  # 注册 展示
  def sign_up_show
    @msg = []
    @msg << "您还没有填写单位信息，请点击下方的[修改单位信息]。" if current_user.department.org_code.blank?
    @msg << "您还没有上传资质证书，请点击下方的[修改资质证书]。" if current_user.department.uploads.blank?
    @msg << "您还没有填写用户信息，请点击下方的[修改用户信息]。" if current_user.name.blank?
  end

  # 注册 提交
  def sign_up_commit
    dep = current_user.department
    logs = prepare_logs_content(dep,"提交","注册完成，提交！")
    dep.change_status_and_write_logs("未审核",logs)
    redirect_to kobe_departments_path
  end

  # 注册 保存单位信息
  def sign_up_update_dep
    dep = current_user.department
    if update_and_write_logs(dep)
      tips_get("更新单位信息成功。")
      redirect_to sign_up_upload_kobe_departments_path
    else
      flash_get(dep.errors.full_messages)
      redirect_back_or
    end
  end

  # 注册 保存附件
  def sign_up_update_upload
    redirect_to sign_up_user_kobe_departments_path
  end

  # 注册 保存用户
  def sign_up_update_user
    if update_and_write_logs(current_user)
      tips_get("更新用户信息成功。")
      redirect_to sign_up_show_kobe_departments_path
    else
      flash_get(current_user.errors.full_messages)
      redirect_back_or
    end
  end

  private  

    def get_dep
      @dep = Department.find(params[:id]) unless params[:id].blank? 
    end
end
