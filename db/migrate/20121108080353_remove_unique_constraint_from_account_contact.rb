class RemoveUniqueConstraintFromAccountContact < ActiveRecord::Migration
  def up
    remove_index :account_contacts, :name => 'unique_account_contact_types'
    add_index :account_contacts, [:contact_id, :account_id, :account_contact_type], :name => 'account_contact_types'
  end

  def down
    remove_index :account_contacts, :name => 'account_contact_types'
    add_index :account_contacts, [:contact_id, :account_id, :account_contact_type], :name => 'unique_account_contact_types'
  end
end
