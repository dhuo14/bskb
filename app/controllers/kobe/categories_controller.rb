# -*- encoding : utf-8 -*-
class Kobe::CategoriesController < KobeController

  skip_before_action :verify_authenticity_token, :only => [ :move, :destroy, :save_params, :save_attr, :remove_params ]
  # protect_from_forgery :except => :index
  before_action :get_category, :only => [ :edit, :update, :destroy ]
  before_action :get_icon, :only => [ :new, :index, :edit ]
  layout false, :only => [ :edit, :new ]

	def index
		@category = Category.new
	end

  def new
  	@category = Category.new
  end

  def edit

  end

  def create
    category = Category.new(category_params)
    if category.save
      tips_get("操作成功。")
      redirect_to kobe_categories_path
    else
      flash_get(category.errors.full_messages)
      render 'index'
    end
  end

  def update
    if @category.update(category_params)
      tips_get("操作成功。")
      redirect_to kobe_categoriess_path
    else
      flash_get(@category.errors.full_messages)
      render 'index'
    end
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

  def set_params
    if params[:format].blank?
      @category = Category.new
    else
      @category = Category.find(params[:format])
    end
  end

  def save_params
    if params[:html].blank?
      render :text => "无效HTML!"
    else
      html = Nokogiri::HTML(params[:html])
      xml = Nokogiri::XML::Document.new
      xml.encoding = "UTF-8"
      xml << "<root>"
      create_node(html, xml.root)
      if params[:id].blank?
        render :text => "无效Category!"
      else
        category = Category.find(params[:id])
        category.update(params: xml.to_xml)
        render :text => "操作成功。"
      end
    end
  end

  def create_node(html, node)
    ol = html.at("ol")
    ol.children.each do | li |
      n = li.at("div")
      next if n.blank?
      new_node = node.add_child("<node>").first
      new_node["name"] = n.text.strip
      n.attributes.each do | k, v |
        next if k == "class"
        new_node[k] = v
      end
      create_node(li, new_node) if li.at("ol")
    end
    return node
  end

  def save_attr
    unless params[:id].blank?
      category = Category.find(params[:id])
      doc = category.params
      if doc.blank?
        xml = Nokogiri::XML::Document.new
        xml.encoding = "UTF-8"
        xml << "<root>"
        node = xml.root.add_child("<node>").first
      else
        xml = Nokogiri::XML(doc)
        node = xml.at("node[@name='#{params[:attr][:name]}']")
        if node.blank?
          node = xml.root.add_child("<node>").first
        end
      end
      params[:attr].each do |k,v|
        if v.blank?
          node.delete(k)
        else
          node[k] = v
        end
      end
      category.update(params: xml.to_xml)
      tips_get("保存成功") 
      redirect_to set_params_kobe_categories_path(params[:id])
    end
  end

  def remove_params
    unless params[:id].blank? && params[:html].blank?
      category = Category.find(params[:id])
      doc = category.params
      xml = Nokogiri::XML(doc)
      html = Nokogiri::HTML(params[:html])
      para = html.at('div')
      node_attr = ""
      para.attributes.each do |k,v|
        next if k == "class" 
        node_attr << "[@#{k}='#{v}']"
      end
      unless para.text.blank?
        node_attr << "[@name='#{para.text}']"
      end
      xml.at("node#{node_attr}").unlink
      category.update(params: xml.to_xml)
      render :text => "删除成功！"
    end
  end


  private  

    # 只允许传递过来的参数
    def category_params  
      params.require(:category).permit(:name, :icon, :sort, :status, :parent_id)  
    end

    def get_category
      @category = Category.find(params[:id]) unless params[:id].blank?
    end

    def get_icon
      @icon = Icon.leaves.map(&:name)
    end
end
