class UpdateAccountContactsForContactRelationships < ActiveRecord::Migration
  def up
    add_column :account_contacts, :account_contact_type, :string
    add_index :account_contacts, [:contact_id, :account_id, :account_contact_type], :unique => true, :name => 'unique_account_contact_types'
    add_index :account_contacts, :account_contact_type, :unique => false, :name => 'unique_account_contact_type_str'
  end

  def down
    remove_column :account_contacts, :relationship
    remove_index :account_contacts, :name => 'unique_account_contact_types'
    remove_index :account_contacts, :name => 'unique_account_contact_type_str'
  end
end
