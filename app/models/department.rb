# -*- encoding : utf-8 -*-

class Department < ActiveRecord::Base
	has_many :user, dependent: :destroy
  # 树形结构
  has_ancestry :cache_depth => true
  default_scope -> {order(:ancestry, :sort, :id)}

  include AboutAncestry

	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	      <node name='单位名称' column='name' required='true'/>
	      <node name='单位简称' column='short_name'/>
	      <node name='组织机构代码' column='org_code' input='true'/>
	      <node name='成立日期' data_type='日期' required='true' hint='以营业执照中的成立日期为准。'/>
	      <node name='单位性质' column='industry' data_type='普通单选' required='true'>
			<optgroup label='行政单位'>
			  <option value='政府机关'>政府机关</option>
			  <option value='事业单位'>事业单位</option>
			</optgroup>
			<optgroup label='企业'>
			  <option value='中央企业'>中央企业</option>
			  <option value='地方国有企业'>地方国有企业</option>
			  <option value='地方私营企业'>地方私营企业</option>
			</optgroup>
		  </node>
		  <node name='单位规模' data_type='普通多选' required='true'>
			<optgroup label='单位人数'>
			  <option value='单位人数1-50人'>小微企业</option>
			  <option value='单位人数50-199人'>中型企业</option>
			  <option value='单位人数200人以上'>大型企业</option>
			</optgroup>
			<optgroup label='年均收益'>
			  <option value='年均收益50万以下'>50万以下</option>
			  <option value='年均收益50万-200万'>50万-200万</option>
			  <option value='年均收益200万以上'>200万以上</option>
			</optgroup>
		  </node>
	      <node name='所在地区' data_type='树形单选'/>
	      <node name='地区id' column='area_id' data_type='数字'/>
	      <node name='详细地址' column='address'/>
	      <node name='是否保密单位' column='is_secret' data_type='布尔' required='true'/>
	      <node name='排序号' column='sort' data_type='字符' required='true' placeholder='在同级单位中的排序号'/>
	      <node name='单位介绍' column='summary' data_type='大文本' required='true' placeholder='不超过800字'/>
	      <node name='备注' data_type='富文本'/>
	    </root>
	  }
	end
end