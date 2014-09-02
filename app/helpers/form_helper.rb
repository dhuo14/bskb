# -*- encoding : utf-8 -*-
module FormHelper
    # 树形选择框
    def tree_select(name, rs, obj_class, options = {})
      checked_max = options.has_key?("checked_max") ? options["checked_max"] : -1 
      keyword = options.has_key?("keyword") ? options["keyword"] : "" 
      input_id = name_to_id(name)
      if rs.blank?
        name_value = id_value = ""
      elsif rs.class == Array
        name_value = rs.map(&:name).join(",")
        id_value = rs.map(&:id).join(",")
      else
        name_value = rs.name
        id_value = rs.id
      end

      str = %Q|
      <div class="input-group">
      #{text_field_tag("box_#{name}", name_value, {:id => "box_#{input_id}", :class => "form-control", :readonly => "readonly", :placeholder => "请选择...",'data-rule-required' => options[:required]})}
      #{hidden_field_tag(name, id_value, {:id => input_id, :class => "tree_select", :obj_class => obj_class, :checked_max => checked_max, :keyword => keyword})}
      <span class="input-group-btn">
      <button class="btn" href="#modal_#{input_id}" data-toggle="modal" type="button">
      <i class="icon-location-arrow"></i>
      </button>
      </span>
      </div>
      #{tree_select_modal(input_id, obj_class, checked_max, keyword)}
      |
      str.html_safe
    end

    def name_to_id(name)
      name.gsub('[]', "").gsub('[', '_').gsub(']', '')
    end

    def tree_select_modal(id,obj_class,checked_max,keyword)
      %Q{
          <div class='modal fade' id='modal_#{id}' tabindex='-1'>
            <div class='modal-dialog'>
              <div class='modal-content'>
                <div class='modal-header'>
                  <button aria-hidden='true' class='close' data-dismiss='modal' type='button'>×</button>
                  <h4 class='modal-title' id='myModalLabel'>请选择</h4>
                </div>
                <div class='modal-body'>
                  <div id='tips_#{id}'></div>
                  <div class="input-group" style="width:80%;margin:15px;">
                    <input type="text" placeholder="请输入关键字..." id="#{id}_keyword" class="form-control">
                    <span class="input-group-addon tree_select_search">
                      <span class="icon-search"></span>
                    </span>
                  </div>
                  <ul id="ztree_#{id}" class="ztree"></ul>
                </div>
                <div class='modal-footer'>
                  <button class='btn btn-default' data-dismiss='modal' type='button' id='cancel_#{id}'>取消</button>
                  <button class='btn btn-primary' type='button' id='ok_#{id}'>确定</button>
                </div>
              </div>
            </div>
          </div>
      }
    end
end