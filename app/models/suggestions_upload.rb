# -*- encoding : utf-8 -*-
class SuggestionsUpload < ActiveRecord::Base
  # attr_accessible :upload

  has_attached_file :upload,
    :styles => {:thumbnail => "30x30",:big =>"976x153#"}
  before_post_process :allow_only_images
  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "id" => read_attribute(:id),
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "thumbnail_url" => (upload_content_type.index("image/") ? upload.url(:thumbnail) : get_icon(read_attribute(:upload_file_name))),
      "delete_url" => upload_path(self),
      "delete_type" => "DELETE" 
    }

  end



  private

  def allow_only_images
    if !(upload.content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$})
      return false 
    end
  end 

  def get_icon(type)
    "/plugins/icons/#{type[type.rindex(".")+1,type.length].downcase}.png"
  end

end
