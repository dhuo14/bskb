# -*- encoding : utf-8 -*-
module XmlFormHelper
  
  # include CreateXmlForm
  include MyFormHelper

  # 红色标记的文本，例如必填项*
  def _red_text(txt)
    return raw "<span class='text-red'>#{txt}</span>".html_safe
  end

  def _create_ms_form()
  	
  end 

end