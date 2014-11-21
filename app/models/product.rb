# -*- encoding : utf-8 -*-
class Product < ActiveRecord::Base
	has_many :uploads, class_name: :ProductsUpload, foreign_key: :master_id
	default_scope -> {order("id desc")}
	belongs_to :category


  # validates_with MyValidator

	include AboutStatus

	# 附件的类
  def self.upload_model
    ProductsUpload
  end

  # 中文意思 状态值 标签颜色 进度 
	def self.status_array
		[
	    ["未提交",0,"orange",10,[1,4,101],[1,0]],
	    ["等待审核",1,"blue",50,[0,4],[3,4]],
	    ["已完成",3,"u",100,[1,4],[3,4]],
	    ["未评价",4,"purple",100,[0,1,101],[3,4]],
	    ["已删除",404,"red",100,[0,1,3,4],nil]
    ]
  end

  # 列表中的状态筛选,current_status当前状态不可以点击
  def self.status_filter(action='')
  	# 列表中不允许出现的
  	limited = [404]
  	arr = self.status_array.delete_if{|a|limited.include?(a[1])}.map{|a|[a[0],a[1]]}
  end

  def cando_list(action='')
    arr = [] 
    # 查看详细
    if [0,1,2,3,4,404].include?(self.status)
    	arr << [self.icon_action("详细"), "/kobe/products/#{self.id}", target: "_blank"]
   	end
    # 修改
    if [0,4,404].include?(self.status)
    	arr << [self.icon_action("修改"), "/kobe/products/#{self.id}/edit"]
    end
	  return arr
  end

end
