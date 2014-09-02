# -*- encoding : utf-8 -*-
class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
    	t.integer :article_id           				  , :comment => "文章ID"
    	t.string :data_file_name           				, :comment => "文件名"
    	t.string :data_content_type           		, :comment => "文件类型"
    	t.string :data_file_size           				, :comment => "文件大小"
    	t.datetime :data_updated_at
      t.timestamps
    end
    add_index :uploads, :article_id
  end
end
