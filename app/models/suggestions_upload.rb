# -*- encoding : utf-8 -*-
class SuggestionsUpload < ActiveRecord::Base
  belongs_to :master, class_name: "Suggestion", foreign_key: "master_id"

  has_attached_file :upload, :styles => {:thumbnail => "45x45",:big =>"1024x768#"}
  # validates_attachment_content_type :upload, :content_type => ['image/jpeg','image/png','application/pdf'], :message => "文件格式有误"
  before_post_process :allow_only_images

  include Rails.application.routes.url_helpers
  include UploadFiles

  # 上传附件的提示 -- 需要跟下面的JS设置匹配
  def self.tips
    '<ol>
      <li>仅支持jpg、jpeg、png、gif、doc、rar、zip、pdf等格式的图片文件；</li>
      <li>单个文件大小不能超过1M；</li>
      <li>上传文件个数不超过10个。</li>
    </ol>'
  end

  # 上传附件的JS设置 -- 需要跟上面的Tips匹配；注意：必须用单引号，避免正则表达式转义
  def self.jquery_setting
    '{
      autoUpload: true,
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|rar|doc?x|zip|pdf)$/i,
      maxNumberOfFiles: 10,
      maxFileSize: 1048576
    }'
  end

end
