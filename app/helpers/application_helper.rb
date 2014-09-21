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
  def oprate_btn2(obj)
    arr = cando_list(obj)
    if arr.length < 5
      return arr.map{|a|link_to(a[1], a[2], class: a[0])}.join("&nbsp;").html_safe
    else 
      tmp = arr.map{|a|"<li>#{link_to(a[1], a[2], class: a[0])}</li>"}.join
      return "<div class='btn-group dropdown' style='margin-bottom:5px'><button class='btn'> 操作 </button><button class='btn dropdown-toggle' data-toggle='dropdown'><span class='caret'></span></button><ul class='dropdown-menu'>#{tmp}</ul></div>".html_safe
    end
  end

  # 格式化日期
  def show_date(d)
    return "" unless d.is_a?(Date) || d.is_a?(Time)
    d.strftime("%Y-%m-%d")
  end

  # 格式化时间
  def show_time(t)
    return "" unless d.is_a?(Time)
    t.strftime("%Y-%m-%d %H:%M:%S")
  end

  # 可以操作列表
  def oprate_btn(obj)
    arr = [] 
    # 查看详细
    arr << link_to(raw("<i class='fa fa-search-plus'></i> 详细"), kobe_suggestion_path(obj), target: "_blank")
    # 标记为已读
    arr << link_to(raw("<i class='fa fa-eye'></i> 标记为已读"), mark_as_read_kobe_suggestion_path(obj), method: :post)
    # 标记为未读
    arr << link_to(raw("<i class='fa fa-eye-slash'></i> 标记为未读"), mark_as_unread_kobe_suggestion_path(obj), method: :post)
    # 删除
    arr << link_to(raw("<i class='fa fa-trash-o'></i> 删除"), kobe_suggestion_path(obj), method: :delete, data: { confirm: "确定要删除吗?" })
    # 彻底删除
    arr << link_to(raw("<i class='fa fa-times'></i> 彻底删除"), kobe_suggestion_path(obj), method: :delete, data: { confirm: "确定要删除吗?" })
    return btn_grop(arr)
  end

  def show_index(index, per = 20)
    params[:page] ||= 1
    (params[:page].to_i - 1) * per + index + 1
  end

  # 按钮组
  def btn_grop(arr)
    return "" if arr.blank?
    first = arr.shift
    unless first.index("<a").nil?
      first.gsub!("<a","<a class='btn btn-sm btn-default' type='button'")
      top = %Q|#{first}
      <button data-toggle='dropdown' class='btn btn-sm btn-default dropdown-toggle' type='button'>
        <i class='fa fa-sort-desc'></i>
      </button>|
    else
      top = %Q|<button class='btn btn-sm btn-default dropdown-toggle' data-toggle='dropdown' type='button'>
        #{first}
        <i class='fa fa-angle-down'></i>
      </button>|
    end
    tmp = arr.map{|c|"<li>#{c}</li>"}.join("\n")
    str = %Q|
    <div class='btn-group'>
      #{top}
      <ul role='menu' class='dropdown-menu'>
        #{tmp}
      </ul>
    </div>|
    return raw str.html_safe
  end

end
