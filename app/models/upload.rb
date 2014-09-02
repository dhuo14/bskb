# -*- encoding : utf-8 -*-
class Upload < ActiveRecord::Base
	belongs_to :article
  has_attached_file :data,
    :path => ":rails_root/public/uploads/:class/:id_partition/:style_:basename.:extension",
    :url => "/uploads/:class/:id_partition/:style_:basename.:extension"
  	validates_attachment_presence :data
#  validates_attachment_content_type :data,
#  :content_type => ['image/jpeg', 'image/jpg', 'image/png','image/pjpeg','image/x-png','image/gif','application/zip','application/x-rar-compressed','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  # def self.destroy_pics(info_id, photos)
  #   DdcgInfoPhoto.find(:all, :conditions =>["ddcg_info_id=#{info_id} and id in(?)",photos]).each do |p|
  #     p.destroy
  #   end
  # end

end
