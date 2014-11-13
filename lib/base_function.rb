# -*- encoding : utf-8 -*-
module BaseFunction

# 获取某实例的字段值
def get_node_value(obj,node,options={})
    # 父节点特殊处理
    if obj.attributes.include?("ancestry")
    	return obj.parent_id if node["name"] == "parent_id" 
    	return obj.parent_name if node["name"] == "父节点名称"
    end
    # 一般情况
    result = ""
    if node.attributes.has_key?("column") && obj.class.attribute_method?(node["column"])
    	result = obj[node["column"]]
    else
    	if obj.class.attribute_method?("details") && !obj["details"].blank?
    		doc = Nokogiri::XML(obj["details"])
    		tmp = doc.xpath("/root/node[@name='#{node["name"]}']").first
    		result = tmp.blank? ? "" : tmp["value"]
    	end
    end
    # 对布尔型的值转换
    if result == true || result == false
    	for_what = options.has_key?("for_what") ? options["for_what"] : "table"
    	result = transform_boolean(result,for_what)
    end
    return result
  end

  #布尔型转换
  def transform_boolean(s,for_what)
  	return s unless [true,false,1,0,'1','0','是','否'].include?(s)
  	if for_what == "table"
  		return (s == true || s.to_s == "1") ? "是" : "否"
  	elsif for_what == "form"
  		return (s == true || s.to_s == "是") ? 1 : 0
  	end
  end

  # 哈希转成syml格式的字符串，供JS调用
  def hash_to_string(ha)
  	if ha.class == Hash
  		arr = []
  		ha.each do |key,value|
  			arr << "#{key}:#{hash_to_string(value)}"
  		end
  		return "{#{arr.join(',')}}"
  	elsif ha.class == String
  		return "'#{ha}'"
  	else
  		return ha
  	end
  end

  # 显示obj记录的信息
  def show_obj_info(obj,xml,options={})
    grid = options.has_key?(:grid) ? options[:grid] : 2
    str = ""
    tbody = ""
    if options.has_key?(:title) && !options[:title].blank?
      str << "<h5><i class='fa fa-chevron-circle-down'></i> #{options[:title]}</h5>"
    else
      str << "<br />"
    end 
    doc = Nokogiri::XML(xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='hidden'][@data_type!='textarea'][@data_type!='richtext']")
    tds.each_slice(grid).with_index do |node,i|
      tbody << "<tr>"
      node.each_with_index{|n,ii|
        tbody << "<td>#{n.attributes["name"]}</td><td>#{get_node_value(obj,n,{"for_what"=>"table"})}</td>"
        tbody << "<td></td><td></td>" * (grid-ii-1) if (n == node.last) && (ii != grid -1)
      }
      tbody << "</tr>"
    end
    # 再生成文本框和富文本框--针对大文本或者富文本
    doc.xpath("/root/node[contains(@data_type,'text')]").each_slice(1) do |node|
      node.each{|n|
        tbody << "<tr>"
          tbody << "<td>#{n.attributes["name"]}</td><td colspan='#{grid*2-1}'>#{get_node_value(obj,n)}</td>"
        tbody << "</tr>"
      }
    end

    str << "<div class='show_obj'><table class='table table-striped table-bordered'><tbody>#{tbody}</tbody></table></div>"
    return str.html_safe
  end

  # 显示评价记录 -- 订单或产品 
  def show_estimates(obj)
  end

  # 显示记录的操作日志
  def show_logs(obj)
    return "暂无记录" if obj.logs.blank?
    str = []
    doc = Nokogiri::XML(obj.logs)
    doc.xpath("/root/node").each do |n|
      opt_time = n.attributes["操作时间"].to_s.split(" ")
      act = n.attributes["操作内容"].to_s[0,2]
      infobar = []
      infobar << "状态:#{obj.status_badge(n.attributes["当前状态"].to_str.to_i)}" if n.attributes.has_key?("当前状态")
      infobar << "姓名:#{n.attributes["操作人姓名"]}"
      infobar << "ID:#{n.attributes["操作人ID"]}"
      infobar << "单位:#{n.attributes["操作人单位"]}"
      infobar << "IP地址:#{n.attributes["IP地址"]}"
      str << %Q|
      <li>
        <time class='cbp_tmtime' datetime=''><span>#{opt_time[1]}</span> <span>#{opt_time[0]}</span></time>
        <i class='cbp_tmicon rounded-x hidden-xs'></i>
        <div class='cbp_tmlabel'>
          <h4><i class="fa fa-chevron-circle-right"></i> #{obj.icon_action(n.attributes["操作内容"].to_str,false)}</h4>
          <div style="display:none;">#{n.attributes["备注"]}</div>
          <p>#{infobar.join("&nbsp;&nbsp;")}</p>
        </div>
      </li>|
    end
    return "<ul class='timeline-v2'>#{str.reverse.join}</ul>"
  end

  # 显示附件
  def show_uploads(obj,picture=false,grid=4)
    result = ""
    # 图片类型
    if picture
      tmp = obj.uploads.map do |file|
        %Q|<div class="col-md-#{12/grid}"><div class="thumbnails thumbnail-style thumbnail-kenburn">
            <a href="#{file.upload.url(:original)}" title="#{file.upload_file_name}" data-rel="fancybox-button" class="fancybox-button zoomer">
              <span class="overlay-zoom overflow-hidden">  
                <img alt="" src="#{file.upload.url(:md)}" class="img-responsive">
                <span class="zoom-icon"></span>                   
              </span>                                              
            </a>
            <div class="caption">
              <p class="word_break">#{file.upload_file_name}<br>[#{number_to_human_size(file.upload_file_size)}]</p>
            </div>                  
          </div></div>|.html_safe
      end
    # 非图片类型
    else
      tmp = obj.uploads.map do |file|
        %Q|<div class="col-md-#{12/grid}">
          <div class="servive-block servive-block-default">
            <a href="#{file.upload.url(:original)}" title="#{file.upload_file_name}" target="_blank">
              <img alt="" src="#{file.to_jq_upload["thumbnail_url"]}">
              <p class="word_break">#{file.upload_file_name}<br>[#{number_to_human_size(file.upload_file_size)}]</p>
            </a>                          
          </div>
        </div>|.html_safe
      end
    end
    tmp.each_slice(grid) do |t|
      result << "<div class='row'>#{t.join}</div>"
    end
    return result.html_safe
  end

  # 生成随机数
  def create_random_chars(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    tmp = ""
    1.upto(len) {|i| tmp << chars[rand(chars.size-1)]}
    return tmp
  end

end