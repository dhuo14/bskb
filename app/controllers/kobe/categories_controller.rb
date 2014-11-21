# -*- encoding : utf-8 -*-
class Kobe::CategoriesController < KobeController

  skip_before_action :verify_authenticity_token, :only => [:move, :destroy, :valid_name]
  # protect_from_forgery :except => :index
  before_action :get_category, :only => [:index, :edit, :show, :update, :destroy]
  layout false, :only => [:edit, :new, :show]

	def index
	end

  def show
    obj_contents = show_obj_info(@category,nil,{title: @category.name})
    @category.params.each do |param|
      obj_contents << show_obj_info(param,CategoriesParam.xml,{title: "参数明细 ##{param.id}"})
    end
    @arr  = []
    @arr << {title: "详细信息", icon: "fa-info", content: obj_contents}
    @arr << {title: "历史记录", icon: "fa-clock-o", content: show_logs(@category)}
  end

  def new
    category = Category.new
    category.parent_id = params[:pid] unless params[:pid].blank?
    slave_objs = [CategoriesParam.new(category_id: category.id)]
    @ms_form = MasterSlaveForm.new(Category.xml, CategoriesParam.xml, category, slave_objs, { form_id: 'new_category', title: '<i class="fa fa-pencil-square-o"></i> 新增品目', action: kobe_categories_path, grid: 2 }, { title: '参数明细', grid: 2 })
  end

  def edit
    slave_objs = @category.params.blank? ? [CategoriesParam.new(category_id: @category.id)] : @category.params
    @ms_form = MasterSlaveForm.new(Category.xml, CategoriesParam.xml, @category, slave_objs, { title: '<i class="fa fa-wrench"></i> 修改品目', action: kobe_category_path(@category), method: "patch", grid: 2 }, { title: '参数明细', grid: 2 })
  end

  def create
    category = create_msform_and_write_logs(Category, CategoriesParam, { :action => "新增品目", :master_title => "基本信息", :slave_title => "参数信息" })
    unless category.id
      redirect_back_or
    else
      redirect_to kobe_categories_path(id: category)
    end
  end

  def update
    update_msform_and_write_logs(@category, CategoriesParam, { :action => "修改品目", :master_title => "基本信息", :slave_title => "参数信息" })
    redirect_to kobe_categories_path(id: @category)
  end

  def destroy
    if @category.destroy
      render :text => "删除成功！"
    else
      render :text => "操作失败！"
    end
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
