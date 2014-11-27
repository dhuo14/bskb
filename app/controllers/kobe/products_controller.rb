# -*- encoding : utf-8 -*-
class Kobe::ProductsController < KobeController

  before_action :get_product, :only => [:show, :edit, :update]

  def index
    @products = Product.where(get_conditions).page params[:page]
  end

  def new
  	product = Product.new
  	category = Category.find(params[:id])
  	product.category_id = params[:id]
    @myform = SingleForm.new(category.params, product, { form_id: "product_form", upload_files: true, action: kobe_products_path(id: category), title: '<i class="fa fa-pencil-square-o"></i> 新增产品', grid: 4 })
  end

  def create
  	category = Category.find(params[:id])
    product = create_and_write_logs(Product, category.params, {}, {category_id: category.id})
    if product
      tips_get("创建产品成功。")
      redirect_to kobe_products_path(id: product)
    else
      flash_get(product.errors.full_messages)
      redirect_to root_path
    end
  end

  def update
    if update_and_write_logs(@product, @product.category.params)
      tips_get("更新产品信息成功。")
      redirect_to kobe_products_path(id: @product)
    else
      flash_get(@product.errors.full_messages)
      redirect_back_or
    end
  end

  def edit
    @myform = SingleForm.new(@product.category.params, @product, { form_id: "product_form", upload_files: true, action: kobe_product_path(@product), method: "patch" })
  end

  def show
    @arr  = []
    @arr << { title: "详细信息", icon: "fa-info", content: show_obj_info(@product,@product.category.params) }
    @arr << { title: "附件", icon: "fa-paperclip", content: show_uploads(@product,true) }
    @arr << { title: "历史记录", icon: "fa-clock-o", content: show_logs(@product) }
  end


  private

  def get_product
    @product = Product.find(params[:id]) unless params[:id].blank? 
  end

end