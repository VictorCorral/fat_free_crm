class ModifyAccountsForEnterpriseImport < ActiveRecord::Migration
  def up
    remove_index "accounts", ["user_id", "name", "deleted_at"]
    change_column :accounts, :name, :string, :length => 255
    change_column :accounts, :website, :text
    change_column :accounts, :email, :text
    change_column :accounts, :category, :text
    change_column :accounts, :toll_free_phone, :text
    change_column :accounts, :phone, :text
    change_column :accounts, :fax, :text
    add_column :accounts, :salesforce_id, :string, :length => 20
    add_column :accounts, :salesforce_parent_id, :string, :length => 20
    add_index :accounts, :salesforce_id
    add_index :accounts, :salesforce_parent_id
    add_index "accounts", ["user_id", "name", "deleted_at"], :name => "index_accounts_on_user_id_and_name_and_deleted_at"
  end

  def down
    remove_index "accounts", ["user_id", "name", "deleted_at"]
    remove_index :accounts, :salesforce_id
    remove_index :accounts, :salesforce_parent_id
    change_column :accounts, :name, :string
    change_column :accounts, :website, :string
    change_column :accounts, :email, :string
    change_column :accounts, :category, :string
    change_column :accounts, :toll_free_phone, :string
    change_column :accounts, :phone, :string
    change_column :accounts, :fax, :string
    remove_column :accounts, :salesforce_id
    remove_column :accounts, :salesforce_parent_id
    add_index "accounts", ["user_id", "name", "deleted_at"], :name => "index_accounts_on_user_id_and_name_and_deleted_at"
  end
end
