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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121019233351) do

  create_table "account_contacts", :force => true do |t|
    t.integer  "account_id", :limit => 10
    t.integer  "contact_id", :limit => 10
    t.datetime "deleted_at", :limit => 23
    t.datetime "created_at", :limit => 23, :null => false
    t.datetime "updated_at", :limit => 23, :null => false
  end

  create_table "account_opportunities", :force => true do |t|
    t.integer  "account_id",     :limit => 10
    t.integer  "opportunity_id", :limit => 10
    t.datetime "deleted_at",     :limit => 23
    t.datetime "created_at",     :limit => 23, :null => false
    t.datetime "updated_at",     :limit => 23, :null => false
  end

  create_table "accounts", :force => true do |t|
    t.integer  "user_id",              :limit => 10
    t.integer  "assigned_to",          :limit => 10
    t.string   "name"
    t.string   "access",               :limit => 8,  :default => "Public"
    t.text     "website"
    t.text     "toll_free_phone"
    t.text     "phone"
    t.text     "fax"
    t.datetime "deleted_at",           :limit => 23
    t.datetime "created_at",           :limit => 23,                       :null => false
    t.datetime "updated_at",           :limit => 23,                       :null => false
    t.text     "email"
    t.string   "background_info"
    t.integer  "rating",               :limit => 10, :default => 0,        :null => false
    t.text     "category"
    t.text     "subscribed_users"
    t.integer  "parent_account_id",    :limit => 10
    t.string   "salesforce_id"
    t.string   "salesforce_parent_id"
  end

  add_index "accounts", ["assigned_to"], :name => "index_accounts_on_assigned_to"
  add_index "accounts", ["salesforce_id"], :name => "index_accounts_on_salesforce_id", :unique => true
  add_index "accounts", ["salesforce_parent_id"], :name => "index_accounts_on_salesforce_parent_id"
  add_index "accounts", ["user_id", "name", "deleted_at"], :name => "index_accounts_on_user_id_and_name_and_deleted_at", :unique => true

  create_table "activities", :force => true do |t|
    t.integer  "user_id",      :limit => 10
    t.integer  "subject_id",   :limit => 10
    t.string   "subject_type"
    t.string   "action",       :limit => 32, :default => "created"
    t.string   "info",                       :default => ""
    t.boolean  "private",                    :default => false
    t.datetime "created_at",   :limit => 23,                        :null => false
    t.datetime "updated_at",   :limit => 23,                        :null => false
  end

  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "addresses", :force => true do |t|
    t.string   "street1"
    t.string   "street2"
    t.string   "city",             :limit => 64
    t.string   "state",            :limit => 64
    t.string   "zipcode",          :limit => 16
    t.string   "country",          :limit => 64
    t.string   "full_address"
    t.string   "address_type",     :limit => 16
    t.integer  "addressable_id",   :limit => 10
    t.string   "addressable_type"
    t.datetime "created_at",       :limit => 23, :null => false
    t.datetime "updated_at",       :limit => 23, :null => false
    t.datetime "deleted_at",       :limit => 23
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "avatars", :force => true do |t|
    t.integer  "user_id",            :limit => 10
    t.integer  "entity_id",          :limit => 10
    t.string   "entity_type"
    t.integer  "image_file_size",    :limit => 10
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.datetime "created_at",         :limit => 23, :null => false
    t.datetime "updated_at",         :limit => 23, :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",          :limit => 10
    t.integer  "commentable_id",   :limit => 10
    t.string   "commentable_type"
    t.boolean  "private"
    t.string   "title",                          :default => ""
    t.text     "comment"
    t.datetime "created_at",       :limit => 23,                         :null => false
    t.datetime "updated_at",       :limit => 23,                         :null => false
    t.string   "state",            :limit => 16, :default => "Expanded", :null => false
  end

  create_table "contact_opportunities", :force => true do |t|
    t.integer  "contact_id",     :limit => 10
    t.integer  "opportunity_id", :limit => 10
    t.string   "role",           :limit => 32
    t.datetime "deleted_at",     :limit => 23
    t.datetime "created_at",     :limit => 23, :null => false
    t.datetime "updated_at",     :limit => 23, :null => false
  end

  create_table "contacts", :force => true do |t|
    t.integer  "user_id",          :limit => 10
    t.integer  "lead_id",          :limit => 10
    t.integer  "assigned_to",      :limit => 10
    t.integer  "reports_to",       :limit => 10
    t.string   "first_name",       :limit => 64,  :default => "",       :null => false
    t.string   "last_name",        :limit => 64,  :default => "",       :null => false
    t.string   "access",           :limit => 8,   :default => "Public"
    t.string   "title",            :limit => 64
    t.string   "department",       :limit => 64
    t.string   "source",           :limit => 32
    t.string   "email",            :limit => 64
    t.string   "alt_email",        :limit => 64
    t.text     "phone"
    t.text     "mobile"
    t.text     "fax"
    t.string   "blog",             :limit => 128
    t.string   "linkedin",         :limit => 128
    t.string   "facebook",         :limit => 128
    t.string   "twitter",          :limit => 128
    t.date     "born_on",          :limit => 10
    t.boolean  "do_not_call",                     :default => false,    :null => false
    t.datetime "deleted_at",       :limit => 23
    t.datetime "created_at",       :limit => 23,                        :null => false
    t.datetime "updated_at",       :limit => 23,                        :null => false
    t.string   "background_info"
    t.string   "skype",            :limit => 128
    t.text     "subscribed_users"
    t.string   "salesforce_id"
  end

  add_index "contacts", ["assigned_to"], :name => "index_contacts_on_assigned_to"
  add_index "contacts", ["salesforce_id"], :name => "index_contacts_on_salesforce_id", :unique => true
  add_index "contacts", ["user_id", "last_name", "deleted_at"], :name => "id_last_name_deleted", :unique => true

  create_table "emails", :force => true do |t|
    t.string   "imap_message_id",                                       :null => false
    t.integer  "user_id",         :limit => 10
    t.integer  "mediator_id",     :limit => 10
    t.string   "mediator_type"
    t.string   "sent_from",                                             :null => false
    t.string   "sent_to",                                               :null => false
    t.string   "cc"
    t.string   "bcc"
    t.string   "subject"
    t.text     "body"
    t.text     "header"
    t.datetime "sent_at",         :limit => 23
    t.datetime "received_at",     :limit => 23
    t.datetime "deleted_at",      :limit => 23
    t.datetime "created_at",      :limit => 23,                         :null => false
    t.datetime "updated_at",      :limit => 23,                         :null => false
    t.string   "state",           :limit => 16, :default => "Expanded", :null => false
  end

  add_index "emails", ["mediator_id", "mediator_type"], :name => "index_emails_on_mediator_id_and_mediator_type"

  create_table "field_groups", :force => true do |t|
    t.string   "name",       :limit => 64
    t.string   "label",      :limit => 128
    t.integer  "position",   :limit => 10
    t.string   "hint"
    t.datetime "created_at", :limit => 23,  :null => false
    t.datetime "updated_at", :limit => 23,  :null => false
    t.integer  "tag_id",     :limit => 10
    t.string   "klass_name", :limit => 32
  end

  create_table "fields", :force => true do |t|
    t.string   "type"
    t.integer  "field_group_id", :limit => 10
    t.integer  "position",       :limit => 10
    t.string   "name",           :limit => 64
    t.string   "label",          :limit => 128
    t.string   "hint"
    t.string   "placeholder"
    t.string   "as",             :limit => 32
    t.text     "collection"
    t.boolean  "disabled"
    t.boolean  "required"
    t.integer  "maxlength",      :limit => 10
    t.datetime "created_at",     :limit => 23,  :null => false
    t.datetime "updated_at",     :limit => 23,  :null => false
    t.integer  "pair_id",        :limit => 10
  end

  add_index "fields", ["field_group_id"], :name => "index_fields_on_field_group_id"
  add_index "fields", ["name"], :name => "index_fields_on_name"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :limit => 23, :null => false
    t.datetime "updated_at", :limit => 23, :null => false
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id", :limit => 10
    t.integer "user_id",  :limit => 10
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id"
  add_index "groups_users", ["group_id"], :name => "index_groups_users_on_group_id"
  add_index "groups_users", ["user_id"], :name => "index_groups_users_on_user_id"

  create_table "leads", :force => true do |t|
    t.integer  "user_id",          :limit => 10
    t.integer  "campaign_id",      :limit => 10
    t.integer  "assigned_to",      :limit => 10
    t.string   "first_name",       :limit => 64,  :default => "",       :null => false
    t.string   "last_name",        :limit => 64,  :default => "",       :null => false
    t.string   "access",           :limit => 8,   :default => "Public"
    t.string   "title",            :limit => 64
    t.string   "company",          :limit => 64
    t.string   "source",           :limit => 32
    t.string   "status",           :limit => 32
    t.string   "referred_by",      :limit => 64
    t.string   "email",            :limit => 64
    t.string   "alt_email",        :limit => 64
    t.string   "phone",            :limit => 32
    t.string   "mobile",           :limit => 32
    t.string   "blog",             :limit => 128
    t.string   "linkedin",         :limit => 128
    t.string   "facebook",         :limit => 128
    t.string   "twitter",          :limit => 128
    t.integer  "rating",           :limit => 10,  :default => 0,        :null => false
    t.boolean  "do_not_call",                     :default => false,    :null => false
    t.datetime "deleted_at",       :limit => 23
    t.datetime "created_at",       :limit => 23,                        :null => false
    t.datetime "updated_at",       :limit => 23,                        :null => false
    t.string   "background_info"
    t.string   "skype",            :limit => 128
    t.text     "subscribed_users"
  end

  add_index "leads", ["assigned_to"], :name => "index_leads_on_assigned_to"
  add_index "leads", ["user_id", "last_name", "deleted_at"], :name => "index_leads_on_user_id_and_last_name_and_deleted_at", :unique => true

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.datetime "created_at", :limit => 23, :null => false
    t.datetime "updated_at", :limit => 23, :null => false
  end

  create_table "opportunities", :force => true do |t|
    t.integer  "user_id",          :limit => 10
    t.integer  "campaign_id",      :limit => 10
    t.integer  "assigned_to",      :limit => 10
    t.string   "name",             :limit => 64,                                :default => "",       :null => false
    t.string   "access",           :limit => 8,                                 :default => "Public"
    t.string   "source",           :limit => 32
    t.string   "stage",            :limit => 32
    t.integer  "probability",      :limit => 10
    t.decimal  "amount",                         :precision => 12, :scale => 2
    t.decimal  "discount",                       :precision => 12, :scale => 2
    t.date     "closes_on",        :limit => 10
    t.datetime "deleted_at",       :limit => 23
    t.datetime "created_at",       :limit => 23,                                                      :null => false
    t.datetime "updated_at",       :limit => 23,                                                      :null => false
    t.string   "background_info"
    t.text     "subscribed_users"
  end

  add_index "opportunities", ["assigned_to"], :name => "index_opportunities_on_assigned_to"
  add_index "opportunities", ["user_id", "name", "deleted_at"], :name => "id_name_deleted", :unique => true

  create_table "permissions", :force => true do |t|
    t.integer  "user_id",    :limit => 10
    t.integer  "asset_id",   :limit => 10
    t.string   "asset_type"
    t.datetime "created_at", :limit => 23, :null => false
    t.datetime "updated_at", :limit => 23, :null => false
    t.integer  "group_id",   :limit => 10
  end

  add_index "permissions", ["asset_id", "asset_type"], :name => "index_permissions_on_asset_id_and_asset_type"
  add_index "permissions", ["group_id"], :name => "index_permissions_on_group_id"
  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "preferences", :force => true do |t|
    t.integer  "user_id",    :limit => 10
    t.string   "name",       :limit => 32, :default => "", :null => false
    t.text     "value"
    t.datetime "created_at", :limit => 23,                 :null => false
    t.datetime "updated_at", :limit => 23,                 :null => false
  end

  add_index "preferences", ["user_id", "name"], :name => "index_preferences_on_user_id_and_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",               :null => false
    t.text     "data"
    t.datetime "created_at", :limit => 23, :null => false
    t.datetime "updated_at", :limit => 23, :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "name",       :limit => 32, :default => "", :null => false
    t.text     "value"
    t.datetime "created_at", :limit => 23,                 :null => false
    t.datetime "updated_at", :limit => 23,                 :null => false
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",        :limit => 10
    t.integer  "taggable_id",   :limit => 10
    t.integer  "tagger_id",     :limit => 10
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at",    :limit => 23
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "user_id",          :limit => 10
    t.integer  "assigned_to",      :limit => 10
    t.integer  "completed_by",     :limit => 10
    t.string   "name",                           :default => "", :null => false
    t.integer  "asset_id",         :limit => 10
    t.string   "asset_type"
    t.string   "priority",         :limit => 32
    t.string   "category",         :limit => 32
    t.string   "bucket",           :limit => 32
    t.datetime "due_at",           :limit => 23
    t.datetime "completed_at",     :limit => 23
    t.datetime "deleted_at",       :limit => 23
    t.datetime "created_at",       :limit => 23,                 :null => false
    t.datetime "updated_at",       :limit => 23,                 :null => false
    t.string   "background_info"
    t.text     "subscribed_users"
  end

  add_index "tasks", ["assigned_to"], :name => "index_tasks_on_assigned_to"
  add_index "tasks", ["user_id", "name", "deleted_at"], :name => "index_tasks_on_user_id_and_name_and_deleted_at", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username",            :limit => 32, :default => "",    :null => false
    t.string   "email",               :limit => 64, :default => "",    :null => false
    t.string   "first_name",          :limit => 32
    t.string   "last_name",           :limit => 32
    t.string   "title",               :limit => 64
    t.string   "company",             :limit => 64
    t.string   "alt_email",           :limit => 64
    t.string   "phone",               :limit => 32
    t.string   "mobile",              :limit => 32
    t.string   "aim",                 :limit => 32
    t.string   "yahoo",               :limit => 32
    t.string   "google",              :limit => 32
    t.string   "skype",               :limit => 32
    t.string   "password_hash",                     :default => "",    :null => false
    t.string   "password_salt",                     :default => "",    :null => false
    t.string   "persistence_token",                 :default => "",    :null => false
    t.string   "perishable_token",                  :default => "",    :null => false
    t.datetime "last_request_at",     :limit => 23
    t.datetime "last_login_at",       :limit => 23
    t.datetime "current_login_at",    :limit => 23
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.integer  "login_count",         :limit => 10, :default => 0,     :null => false
    t.datetime "deleted_at",          :limit => 23
    t.datetime "created_at",          :limit => 23,                    :null => false
    t.datetime "updated_at",          :limit => 23,                    :null => false
    t.boolean  "admin",                             :default => false, :null => false
    t.datetime "suspended_at",        :limit => 23
    t.string   "single_access_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_remember_token"
  add_index "users", ["username", "deleted_at"], :name => "index_users_on_username_and_deleted_at", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",                     :null => false
    t.integer  "item_id",        :limit => 10,  :null => false
    t.string   "event",          :limit => 512
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at",     :limit => 23
    t.text     "object_changes"
    t.integer  "related_id",     :limit => 10
    t.string   "related_type"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["whodunnit"], :name => "index_versions_on_whodunnit"

end
