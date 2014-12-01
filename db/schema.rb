# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141121072504) do

  create_table "areas", force: true do |t|
    t.string   "name"
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.string   "code"
    t.integer  "sort"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_contents", force: true do |t|
    t.integer  "article_id", null: false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", force: true do |t|
    t.string   "title"
    t.integer  "user_id",                       null: false
    t.datetime "publish_time"
    t.string   "tags"
    t.integer  "new_days",          default: 3, null: false
    t.integer  "top_type",          default: 0, null: false
    t.integer  "access_permission", default: 0, null: false
    t.integer  "status",            default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["tags"], name: "index_articles_on_tags", using: :btree
  add_index "articles", ["title"], name: "index_articles_on_title", using: :btree
  add_index "articles", ["user_id"], name: "index_articles_on_user_id", using: :btree

  create_table "articles_categories", force: true do |t|
    t.integer "article_id",  null: false
    t.integer "category_id", null: false
  end

  add_index "articles_categories", ["article_id", "category_id"], name: "index_articles_categories_on_article_id_and_category_id", using: :btree

  create_table "catalogs", force: true do |t|
    t.string   "name",                                 null: false
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.string   "icon"
    t.integer  "status",         limit: 2, default: 0, null: false
    t.integer  "sort"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "catalogs", ["name"], name: "index_catalogs_on_name", unique: true, using: :btree

  create_table "categories", force: true do |t|
    t.string   "name",                                 null: false
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.integer  "status",         limit: 2, default: 0, null: false
    t.integer  "sort"
    t.text     "audit_rules"
    t.text     "details"
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "categories_params", force: true do |t|
    t.integer  "category_id", default: 0,     null: false
    t.string   "name",                        null: false
    t.string   "data_type",                   null: false
    t.string   "column"
    t.boolean  "is_required", default: false, null: false
    t.string   "hint"
    t.string   "placeholder"
    t.text     "data"
    t.string   "rule"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_params", ["category_id"], name: "index_categories_params_on_category_id", using: :btree

  create_table "departments", force: true do |t|
    t.string   "name",                                     null: false
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.integer  "status",         limit: 2, default: 0,     null: false
    t.string   "short_name"
    t.string   "org_code"
    t.string   "legal_name"
    t.string   "legal_number"
    t.integer  "area_id"
    t.string   "address"
    t.string   "post_code"
    t.string   "website"
    t.string   "domain"
    t.string   "bank"
    t.string   "bank_code"
    t.string   "industry"
    t.string   "cgr_nature"
    t.string   "gys_nature"
    t.string   "capital"
    t.string   "license"
    t.string   "tax"
    t.string   "employee"
    t.string   "turnover"
    t.string   "tel"
    t.string   "fax"
    t.string   "categories"
    t.string   "lng"
    t.string   "lat"
    t.text     "summary"
    t.boolean  "is_secret",                default: false, null: false
    t.boolean  "is_blacklist",             default: false, null: false
    t.integer  "sort"
    t.text     "details"
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["ancestry"], name: "index_departments_on_ancestry", using: :btree
  add_index "departments", ["name"], name: "index_departments_on_name", unique: true, using: :btree

  create_table "departments_uploads", force: true do |t|
    t.integer  "master_id",           default: 0
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments_uploads", ["master_id"], name: "index_departments_uploads_on_master_id", using: :btree

  create_table "icons", force: true do |t|
    t.string  "name",                                 null: false
    t.string  "ancestry"
    t.integer "ancestry_depth"
    t.string  "transfer"
    t.integer "status",         limit: 2, default: 0, null: false
    t.integer "sort"
  end

  add_index "icons", ["name"], name: "index_icons_on_name", unique: true, using: :btree

  create_table "menus", force: true do |t|
    t.string   "name",                                 null: false
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.string   "icon"
    t.string   "route_path"
    t.integer  "status",         limit: 2, default: 0, null: false
    t.integer  "sort"
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "menus", ["name"], name: "index_menus_on_name", unique: true, using: :btree

  create_table "menus_users", force: true do |t|
    t.integer "user_id", null: false
    t.integer "menu_id", null: false
  end

  add_index "menus_users", ["user_id", "menu_id"], name: "index_menus_users_on_user_id_and_menu_id", using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "sender_id",                         null: false
    t.integer  "receiver_id",                       null: false
    t.integer  "category",                          null: false
    t.string   "title"
    t.string   "content"
    t.integer  "status",      limit: 2, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["receiver_id"], name: "index_notifications_on_receiver_id", using: :btree
  add_index "notifications", ["sender_id"], name: "index_notifications_on_sender_id", using: :btree

  create_table "orders", force: true do |t|
    t.string   "name",                                                            null: false
    t.string   "sn"
    t.string   "contract_sn"
    t.string   "buyer"
    t.string   "payer"
    t.string   "buyer_code"
    t.string   "seller"
    t.string   "seller_code"
    t.decimal  "bugget",                   precision: 13, scale: 2
    t.decimal  "total",                    precision: 13, scale: 2, default: 0.0, null: false
    t.date     "deliver_at"
    t.string   "invoice_number"
    t.text     "summary"
    t.integer  "user_id",                                           default: 0,   null: false
    t.integer  "status",         limit: 2,                          default: 0,   null: false
    t.datetime "effective_time"
    t.text     "details"
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["sn"], name: "index_orders_on_sn", unique: true, using: :btree

  create_table "orders_products", force: true do |t|
    t.integer  "order_id",                               default: 0,   null: false
    t.string   "category_code",                                        null: false
    t.integer  "product_id",                             default: 0,   null: false
    t.string   "brand"
    t.string   "model"
    t.string   "version"
    t.string   "unit"
    t.decimal  "market_price",  precision: 13, scale: 2
    t.decimal  "bid_price",     precision: 13, scale: 2
    t.decimal  "price",         precision: 13, scale: 2, default: 0.0, null: false
    t.integer  "quantity",                               default: 0,   null: false
    t.decimal  "total",         precision: 13, scale: 2, default: 0.0, null: false
    t.text     "summary"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders_products", ["category_code"], name: "index_orders_products_on_category_code", using: :btree
  add_index "orders_products", ["order_id"], name: "index_orders_products_on_order_id", using: :btree

  create_table "orders_uploads", force: true do |t|
    t.integer  "master_id",           default: 0
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders_uploads", ["master_id"], name: "index_Orders_uploads_on_master_id", using: :btree

  create_table "permissions", force: true do |t|
    t.string   "name",                       null: false
    t.string   "action",                     null: false
    t.string   "subject",                    null: false
    t.boolean  "is_model",    default: true, null: false
    t.string   "conditions"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["action", "subject"], name: "index_permissions_on_action_and_subject", using: :btree
  add_index "permissions", ["name"], name: "index_permissions_on_name", using: :btree

  create_table "permissions_roles", force: true do |t|
    t.integer "role_id",       null: false
    t.integer "permission_id", null: false
  end

  add_index "permissions_roles", ["role_id", "permission_id"], name: "index_permissions_roles_on_role_id_and_permission_id", using: :btree

  create_table "products", force: true do |t|
    t.integer  "item_id",                                          default: 0,   null: false
    t.integer  "category_id",                                      default: 0,   null: false
    t.string   "category_code",                                    default: "0", null: false
    t.string   "brand"
    t.string   "model"
    t.string   "version"
    t.string   "unit"
    t.decimal  "market_price",            precision: 13, scale: 2
    t.decimal  "bid_price",               precision: 13, scale: 2
    t.text     "summary"
    t.integer  "status",        limit: 2,                          default: 0,   null: false
    t.text     "details"
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products_uploads", force: true do |t|
    t.integer  "master_id",           default: 0
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products_uploads", ["master_id"], name: "index_products_uploads_on_master_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",                                 null: false
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.integer  "status",         limit: 2, default: 0, null: false
    t.integer  "sort"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "roles_users", force: true do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", using: :btree

  create_table "suggestions", force: true do |t|
    t.text     "content",                          null: false
    t.string   "email"
    t.string   "mobile"
    t.string   "QQ"
    t.integer  "status",     limit: 2, default: 0, null: false
    t.text     "logs"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suggestions_uploads", force: true do |t|
    t.integer  "master_id",           default: 0
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suggestions_uploads", ["master_id"], name: "index_suggestions_uploads_on_master_id", using: :btree

  create_table "users", force: true do |t|
    t.integer  "department_id",                default: 0
    t.string   "login"
    t.string   "password_digest",                              null: false
    t.string   "remember_token"
    t.string   "name"
    t.date     "birthday"
    t.string   "portrait"
    t.string   "gender",             limit: 2
    t.string   "identity_num"
    t.string   "identity_pic"
    t.string   "email"
    t.string   "mobile"
    t.boolean  "is_visible",                   default: true,  null: false
    t.string   "tel"
    t.string   "fax"
    t.boolean  "is_admin",                     default: false, null: false
    t.integer  "status",                       default: 0,     null: false
    t.string   "duty"
    t.string   "professional_title"
    t.text     "bio"
    t.text     "details"
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

end
