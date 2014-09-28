# -*- encoding : utf-8 -*-

class Department < ActiveRecord::Base
	has_many :user, dependent: :destroy
  # 树形结构
  has_ancestry :cache_depth => true
  default_scope -> {order(:ancestry, :sort, :id)}

  validates :name, presence: true, length: { in: 6..30 }, uniqueness: { case_sensitive: false }

  include AboutAncestry
  include AboutStatus

  def self.status_array
		[
      ["资料未填写",0,"light",10], 
      ["正常",1,"u",100], 
      ["冻结",2,"yellow",100], 
      ["未审核",3,"orange",20],
      ["已删除",98,"red",100]
    ]
  end
  
	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	      <node name='单位名称' column='name' hint='必须与参照营业执照中的单位名称保持一致' rules='{required:true, maxlength:30, minlength:6}' display='disabled'/>
	      <node name='单位简称' column='short_name'/>
	      <node name='组织机构代码' column='org_code' hint='请参照组织机构代码证上的号码' rules='{required:true, maxlength:10, minlength:5}' messages='请输入5-10个字符'/>
	      <node name='成立日期' icon='calendar' hint='以营业执照中的成立日期为准' rules='{required:true, dateISO:true}'/>
	      <node name='单位性质' column='industry' data_type='checkbox' rules='{required:true}' data='["政府机关","事业单位","中央企业","地方国有企业","私营企业"]' rules='{required:true}'/>
		  	<node name='单位人数' data_type='radio' rules='{required:true}' data='["20人以下","21-100人","101-500人","501-1001人","1001-10000人","1000人以上"]'/>
	      <node name='注册资金' column='capital' icon='jpy' rules='{required:true}'/>
	      <node name='所在地区' data_type='tree_select' url='/home/treetest'/>
	      <node name='邮政编码' column='area_id' rules='{required:true, number:true}'/>
	      <node name='详细地址' column='address'/>
	      <node name='邮箱地址' icon='envelope'/>
	      <node name='是否保密单位' column='is_secret' data_type='radio' data='[[1,"是"],[0,"否"]]'/>
	      <node name='排序号' column='sort' placeholder='在同级单位中的排序号' hint='数字越小排序越靠前'/>
	      <node name='单位介绍' column='summary' data_type='textarea' rules='{required:true}' placeholder='不超过800字'/>
	      <node name='备注' data_type='richtext'/>
	    </root>
	  }
	end

	def cando_list(action='')
    arr = [] 
    # 修改
    if [0,404].include?(self.status)
      arr << ["<i class='fa fa-pencil'></i> 修改", "javascript:void(0)", onClick: "show_content('/kobe/departments/#{self.id}/edit','dep .show_content')"]
    end
    return arr
  end
end