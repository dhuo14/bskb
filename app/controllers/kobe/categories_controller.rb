# -*- encoding : utf-8 -*-
class Kobe::CategoriesController < KobeController

  skip_before_action :verify_authenticity_token, :only => [:move, :destroy, :valid_name]
  # protect_from_forgery :except => :index
  before_action :get_category, :only => [:index, :edit, :show, :update, :delete, :destroy, :freeze, :update_freeze, :recover, :update_recover]
  layout false, :only => [:edit, :new, :show, :delete, :freeze, :recover]

	def index
	end

  def show
    obj_contents = ""
    create_objs_from_xml_model(@category.params, CategoriesParam).each_with_index do |param,index|
      obj_contents << show_obj_info(param,CategoriesParam.xml,{title: "参数明细 ##{index+1}"})
    end
    @arr  = []
    @arr << {title: "参数信息", icon: "fa-info", content: obj_contents}
    @arr << {title: "历史记录", icon: "fa-clock-o", content: show_logs(@category)}
  end

  def new
    category = Category.new
    category.parent_id = params[:pid] unless params[:pid].blank?
    slave_objs = [CategoriesParam.new]
    @ms_form = MasterSlaveForm.new(Category.xml, CategoriesParam.xml, category, slave_objs, { form_id: 'new_category', title: '<i class="fa fa-pencil-square-o"></i> 新增品目', action: kobe_categories_path, grid: 2 }, { title: '参数明细', grid: 4 })
  end

  def edit
    slave_objs = create_objs_from_xml_model(@category.params, CategoriesParam)
    @my_form = MasterSlaveForm.new(Category.xml, CategoriesParam.xml, @category, slave_objs, { action: kobe_category_path(@category), method: "patch", grid: 2 }, { title: '参数明细', grid: 4 })
  end

  def create
    category = create_and_write_logs(Category, Category.xml, { :action => "新增品目" }, { "params" => create_xml(CategoriesParam.xml, CategoriesParam) })
    unless category.id
      redirect_back_or
    else
      redirect_to kobe_categories_path(id: category)
    end
  end

  def update
    update_and_write_logs(@category, Category.xml, { :action => "修改品目" }, { "params" => create_xml(CategoriesParam.xml, CategoriesParam) })
    redirect_to kobe_categories_path(id: @category)
  end

  # 删除
  def destroy
    logs = @category.has_children? ? batch_logs("删除") : prepare_logs_content(@category, "删除")
    render :text => @category.ztree_change_status_and_write_logs("已删除", logs) ? "删除成功！" : "操作失败！"
  end

  # 删除
  def delete
  end
  
  def destroy
    if @category.ztree_change_status_and_write_logs("已删除", batch_logs("删除",params[:opt_liyou]))
      tips_get("删除单位成功。")
    else
      flash_get(@category.errors.full_messages)
    end
    redirect_to kobe_categories_path(id: @category.parent_id)
  end

  # 冻结
  def freeze
  end

  def update_freeze
    if @category.ztree_change_status_and_write_logs("冻结", batch_logs("冻结",params[:opt_liyou]))
      tips_get("冻结单位成功。")
    else
      flash_get(@category.errors.full_messages)
    end
    redirect_to kobe_categories_path(id: @category)
  end

  # 恢复
  def recover
  end

  def update_recover
    if @category.ztree_change_status_and_write_logs("正常", batch_logs("恢复",params[:opt_liyou]))
      tips_get("恢复单位成功。")
    else
      flash_get(@category.errors.full_messages)
    end
    redirect_to kobe_categories_path(id: @category)
  end

  def move
    ztree_move(Category)
  end

  def ztree
    ztree_json(Category)
  end

  # 验证品目名称
  def valid_name
    params[:obj_id] ||= 0
    render :text => valid_remote(Category, ["name = ? and id != ?", params[:categories][:name], params[:obj_id]])
  end

  private
    def get_category
      @category = Category.find(params[:id]) unless params[:id].blank?
    end

end
