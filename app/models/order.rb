# -*- encoding : utf-8 -*-
class Order < ActiveRecord::Base
	has_many :products, class_name: :OrdersProduct
	has_many :uploads, class_name: :OrdersUpload, foreign_key: :master_id
	include AboutStatus

	# 附件的类
  def self.upload_model
    OrdersUpload
  end

	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node name='项目名称' column='name' hint='项目名称应该包含主要产品信息，例如：XXX直属库输送机采购项目' rules='{required:true, maxlength:80, minlength:6}'/>
	      <node name='采购单位' column='buyer' hint='一般是使用单位。' display='readonly' rules='{required:true}'/>
	      <node name='发票抬头' column='payer' hint='付款单位，默认与采购单位相同。' rules='{required:true}'/>
	      <node name='供应商名称' column='seller' rules='{required:true}'/>
	      <node name='交付日期' column='deliver_at' class='date_select' rules='{required:true, dateISO:true}'/>
	      <node name='预算金额（元）' column='bugget' rules='{required:true, number:true}'/>
	      <node name='发票编号' column='invoice_number' hint='多张发票请用逗号隔开'/>
	      <node name='备注' column='summary' data_type='textarea' placeholder='不超过800字'/>
	    </root>
	  }
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
    	arr << [self.icon_action("详细"), "/kobe/orders/#{self.id}", target: "_blank"]
   	end
    # 修改
    if [0,4,404].include?(self.status)
    	arr << [self.icon_action("修改"), "/kobe/orders/#{self.id}/edit"]
    end
    # 修改
    if [0,4,404].include?(self.status)
    	arr << [self.icon_action("提交"), "/kobe/orders/#{self.id}/submit"]
    end
    # 审核
    if [0,1,404].include?(self.status)
    	arr << [self.icon_action("确认订单"), "/kobe/orders/#{self.id}/confirm"]
    end
    # 审核
    if [0,1,404].include?(self.status)
    	arr << [self.icon_action("审核"), "/kobe/orders/#{self.id}/audit"]
    end
    # 审核
    if [0,1,404].include?(self.status)
    	arr << [self.icon_action("打印"), "/kobe/orders/#{self.id}/print", target: "_blank"]
    end
    # 删除
    if [0,1,3,4].include?(self.status)
	    arr << [self.icon_action("删除"), "/kobe/orders/#{self.id}", method: :delete, data: {confirm: "确定要删除吗?"}]
	  end
    # 彻底删除
    if self.status == 404
	    arr << [self.icon_action("彻底删除"), "/kobe/orders/#{self.id}", method: :delete, data: {confirm: "删除后不可恢复，确定要删除吗?"}]
	  end
	  return arr
  end

end
