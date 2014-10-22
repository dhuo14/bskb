//= require plugins/sky-forms/version-2.0.1/js/jquery.form.min
//= require plugins/sky-forms/version-2.0.1/js/jquery.validate.min
//= require plugins/sky-forms/version-2.0.1/js/jquery.maskedinput.min
//= require plugins/sky-forms/version-2.0.1/js/jquery-ui.min
//= require plugins/masking
//= require plugins/datepicker
//= require plugins/dialog-select
//= require jquery-fileupload

$(function() {
  // Masking.initMasking();
  // 日期选择
  Datepicker.initDatepicker();
  // 上传附件
  $('form.fileupload_form').each(function(){
	  var url = $(this).prop("action");
	  var this_form = $(this);
	  if (url.lastIndexOf("master_id") > 0){
	    $.getJSON(url, function(files){
	      var fu = this_form.data('blueimpFileupload'), template;
	      fu._adjustMaxNumberOfFiles(-files.length);
	      console.log(files);
	      template = fu._renderDownload(files).appendTo($('#'+ this_form.attr("id") +' .files'));
	      fu._reflow = fu._transition && template.length && template[0].offsetWidth;
	      template.addClass('in');
	      $('#loading').remove();
	    });
	  }
	});
});