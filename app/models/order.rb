# -*- encoding : utf-8 -*-
class Order < ActiveRecord::Base
	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node name='parent_id' data_type='hidden'/>
	    	<node name='项目名称' column='name' hint='项目名称应该包含主要产品信息，例如：XXX直属库输送机采购项目' rules='{required:true, maxlength:80, minlength:6}'/>
	      <node name='采购单位' column='buyer_name' hint='必须与参照营业执照中的单位名称保持一致' rules='{required:true}'/>
	      <node name='单位简称' column='short_name' display='disabled'/>
	      <node name='组织机构代码' column='org_code' hint='请参照组织机构代码证上的号码' rules='{required:true, maxlength:10, minlength:5}' messages='请输入5-10个字符'/>
	      <node name='成立日期' class='date_select' hint='以营业执照中的成立日期为准' rules='{required:true, dateISO:true}'/>
	      <node name='单位性质' column='industry' data_type='checkbox' rules='{required:true}' data='["政府机关","事业单位","中央企业","地方国有企业","私营企业"]' rules='{required:true}'/>
		  	<node name='单位人数' data_type='radio' rules='{required:true}' data='["20人以下","21-100人","101-500人","501-1001人","1001-10000人","1000人以上"]'/>
	      <node name='注册资金' column='capital' icon='jpy' rules='{required:true}'/>
	      <node name='所在地区' class='tree_radio' json_url='/json/areas' partner='area_id' rules='{required:true}'/>
	      <node column='area_id' data_type='hidden'/>
	      <node name='主营产品' class='tree_checkbox' json_url='/json/categories' limited="3" partner='categories'/>
	      <node column='categories' data_type='hidden'/>
	      <node name='box_checkbox测试' class='box_checkbox' json_url='/json/menus' limited="4" partner='box_checkbox测试ID'/>
	      <node name='box_checkbox测试ID' data_type='hidden'/>
	      <node name='box_radio测试' class='box_radio' json_url='/json/roles' partner='box_radio测试ID'/>
	      <node name='box_radio测试ID' data_type='hidden'/>
	      <node name='邮政编码' column='post_code' rules='{required:true, number:true}'/>
	      <node name='详细地址' column='address'/>
	      <node name='邮箱地址' icon='envelope'/>
	      <node name='是否保密单位' column='is_secret' data_type='radio' data='[[1,"是"],[0,"否"]]'/>
	      <node name='排序号' column='sort' placeholder='在同级单位中的排序号' hint='数字越小排序越靠前'/>
	      <node name='单位介绍' column='summary' data_type='textarea' rules='{required:true}' placeholder='不超过800字'/>
	      <node name='备注' data_type='richtext'/>
	    </root>
	  }
	end
end
