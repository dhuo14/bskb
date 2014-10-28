# -*- encoding : utf-8 -*-
class MyForm
	include ActionView::Helpers
	include XmlFormHelper

	def get_table_name(obj=self.obj)
		obj.class.to_s.tableize
	end

  def get_master_input_part
  	self.get_input_str
  end

  def get_input_str(xml=self.xml,obj=self.obj,table_name=self.table_name,grid=self.options[:grid])
  	input_str = ""
  	doc = Nokogiri::XML(xml)
  	# 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'、'隐藏'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='textarea'][@data_type!='richtext'][@data_type!='hidden']")
    tds.each_slice(grid).with_index do |node,i|
      tmp = ""
      node.each{|n| tmp << _create_text_field(self,n,obj,table_name,grid)}
      input_str << content_tag(:div, raw(tmp).html_safe, :class=>'row')
    end
    # 再生成文本框和富文本框--针对大文本、富文本或者隐藏域
    doc.xpath("/root/node[@data_type='textarea'] | /root/node[@data_type='richtext'] | /root/node[@data_type='hidden']").each{|n|
      unless n.attributes["data_type"].to_s == "hidden"
        input_str << content_tag(:div, raw(_create_text_field(self,n,obj,table_name,grid)).html_safe, :class=>'row')
      else
        input_str << _create_text_field(self,n,obj,table_name,grid)
      end
    }
    return input_str
  end

end