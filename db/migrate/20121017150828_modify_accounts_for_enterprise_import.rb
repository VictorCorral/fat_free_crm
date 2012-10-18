class ModifyAccountsForEnterpriseImport < ActiveRecord::Migration
  def up
    change_column :accounts, :name, :text
    change_column :accounts, :website, :text
    change_column :accounts, :email, :text
    change_column :accounts, :category, :text
    change_column :accounts, :toll_free_phone, :text
    change_column :accounts, :phone, :text
    change_column :accounts, :fax, :text
    add_column :accounts, :salesforce_id, :text
    add_column :accounts, :salesforce_parent_id, :text
  end

  def down
    change_column :accounts, :name, :string
    change_column :accounts, :website, :string
    change_column :accounts, :email, :string
    change_column :accounts, :category, :string
    change_column :accounts, :toll_free_phone, :string
    change_column :accounts, :phone, :string
    change_column :accounts, :fax, :string
    remove_column :accounts, :salesforce_id, :text
    remove_column :accounts, :salesforce_parent_id, :text
  end
end
