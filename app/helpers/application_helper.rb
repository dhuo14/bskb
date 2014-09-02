# -*- encoding : utf-8 -*-
module ApplicationHelper

  # 显示未读的系统消息（状态栏消息）
  def show_notification(obj)
    str = %Q|
            <li>
              <a href='#'>
                <div class='widget-body'>
                  <div class='pull-left icon'>
                    <i class='#{obj.category.icon} #{obj.category.icon_color}'></i>
                  </div>
                  <div class='pull-left text'>
                    #{obj.content}
                    <small class='text-muted'>#{obj.created_at}</small>
                  </div>
                </div>
              </a>
            </li>
    |
    return str.html_safe
  end

  # simple_form表单提交按钮
  def form_btn(f)
    str = %Q|
    <div class="form-actions form-actions-padding-sm" style="background-color: #FFFFFF;">
      <div class="row">
        <div class="col-sm-9 col-sm-offset-3">
          #{ f.button :submit, ' 保 存 ', :class => 'btn-primary btn-lg' } &nbsp;&nbsp; 
          #{ f.button :button, ' 重 置 ', :type => 'reset', :class => 'btn-lg' }
        </div>
      </div>
     </div>
    |
    return str.html_safe
  end

  # 操作列表
  def oprate_btn(obj)
    arr = cando_list(obj)
    if arr.length < 5
      return arr.map{|a|link_to(a[1], a[2], class: a[0])}.join("&nbsp;").html_safe
    else 
      tmp = arr.map{|a|"<li>#{link_to(a[1], a[2], class: a[0])}</li>"}.join
      return "<div class='btn-group dropdown' style='margin-bottom:5px'><button class='btn'> 操作 </button><button class='btn dropdown-toggle' data-toggle='dropdown'><span class='caret'></span></button><ul class='dropdown-menu'>#{tmp}</ul></div>".html_safe
    end
  end

  def show_index(index, per = 20)
    params[:page] ||= 1
    (params[:page].to_i - 1) * per + index + 1
  end

end
