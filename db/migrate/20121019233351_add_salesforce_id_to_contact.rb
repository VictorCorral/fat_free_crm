class AddSalesforceIdToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :salesforce_id, :string
    add_index :contacts, :salesforce_id #, :unique => true
    change_column :contacts, :phone, :text
    change_column :contacts, :mobile, :text
    change_column :contacts, :fax, :text
    change_column :contacts, :title, :text
    change_column :contacts, :department, :text
  end

  def down
    remove_index :contacts, :salesforce_id
    remove_column :contacts, :salesforce_id
    change_column :contacts, :phone, :string
    change_column :contacts, :mobile, :string
    change_column :contacts, :fax, :string
    change_column :contacts, :title, :string
    change_column :contacts, :department, :string

#    remove_index :contacts, :salesforce_id
  end
end
