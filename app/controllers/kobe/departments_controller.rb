# -*- encoding : utf-8 -*-
class Kobe::DepartmentsController < KobeController

  skip_before_action :verify_authenticity_token, :only => [ :move, :valid_dep_name, :destroy ]
  before_action :get_dep, :only => [:index, :show, :edit, :update, :destroy, :freeze ]
  layout :false, :only => [ :show, :edit, :new ]

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

  private  

    def get_dep
      @dep = Department.find(params[:id]) unless params[:id].blank? 
    end
end
