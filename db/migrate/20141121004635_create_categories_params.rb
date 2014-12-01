# -*- encoding : utf-8 -*-
class CreateCategoriesParams < ActiveRecord::Migration
  def change
    create_table :categories_params do |t|
    	t.belongs_to :category, :default => 0, :comment => "品目ID", :null => false
      t.string :name, :comment => "参数名称", :null => false
      t.string :data_type, :comment => "参数类型", :null => false
      t.string :column, :comment => "参数别名"
      t.boolean :is_required, :comment => "是否必填", :default => 0, :null => false
      t.string :hint, :comment => "提示"
      t.string :placeholder, :comment => "占位符"
      t.text :data, :comment => "选择项"
      t.string :rule, :comment => "参数格式"
      t.text :details, :comment => "明细"
      t.timestamps
    end
    add_index :categories_params, :category_id
  end
end
