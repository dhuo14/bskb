//= require ztree_show

// 全选、取消全选的事件  
function selectAll(){  
    if ($("#check_all").attr("checked")) {  
        $(":checkbox").attr("checked", true);  
    } else {  
        $(":checkbox").attr("checked", false);  
    }  
};
// 子复选框的事件  
function setSelectAll(){  
    //当没有选中某个子复选框时，SelectAll取消选中  
    if (!$(this).checked) {  
        $("#check_all").attr("checked", false);  
    }  
    var chsub = $(".list_table tbody input[type='checkbox']").length; //获取subcheck的个数  
    var checkedsub = $(".list_table tbody input[type='checkbox']:checked").length; //获取选中的subcheck的个数  
    if (checkedsub == chsub) {  
        $("#check_all").attr("checked", true);  
    }else {
        $("#check_all").attr("checked", false); 
    }
};

// Ajax加载页面
function show_content(url,div) {
    $.ajax({
        type: "get",
        url: url,
        async: false,
        cache: false,
        dataType: "html",
        success: function(data) {
            $(div).html(data);
            // 获取当前tab的id 加载页面以后返回当前tab
            // if($(div).has('form').length != 0) {
            //     var tab_id = $(div).parent().attr("id").split("_")[0];
            //     $(div + " form").append("<input type='hidden' name='tab_id' value='"+tab_id+"'>");
            // }
        },
        error: function (data, textStatus){
            alert("操作失败，请重试！错误代码：" + textStatus + "\n" + data, init_ztree());
        }
    });
}
