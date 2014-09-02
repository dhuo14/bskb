# -*- encoding : utf-8 -*-
module CategoryHelper
	# 设置参数的弹框
	def set_params(xml)
		str = %Q{
			<div class='row'>
				<div class='box box-nomargin'>
					<div class='box-content'>
						<div class='dd dd-nestable'>
							
		}
		doc = Nokogiri::XML(xml)
		unless xml.blank?
			root = doc.at('/root')
			str << show_node(root)
		end
		str << %Q{
						</div>
			  	</div>
      	</div>
      </div>
		}

		return raw str.html_safe
	end


	def show_node(node,i=0)
		str = "<ol class='dd-list'>"
		node.xpath('node').each_with_index do | n, index |
			str << %Q{
				<li class='dd-item' data-id='#{i}-#{index+1}'>
					<div class='dd-handle'
			}
			n.attributes.each do | k, v |
				next if k == "name"
				str << " #{k}='#{v}'"
			end
			str << %Q{
				>#{n['name']}</div>
					<span class='actions pull-right li_operate'>
						<a class='btn btn-link edit has-tooltip' data-placement='top' title='修改' data-toggle='modal' href='#modal-form'>
							<i class='icon-pencil'></i>
						</a>
						<a class='btn btn-link remove has-tooltip' data-placement='top' href='javascript:void(0);' title='删除'>
							<i class='icon-remove'></i>
						</a>
					</span>
				
			}
			str << show_node(n,index+1) unless n.xpath('node').blank?
			str << %Q{
          </li>
			}
		end
		str << "</ol>"
	end

end