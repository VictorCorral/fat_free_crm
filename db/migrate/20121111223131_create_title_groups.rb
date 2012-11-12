class CreateTitleGroups < ActiveRecord::Migration
  def up
   #Get rid of relationship info on direct account_contact relationships
    remove_column :account_contacts, :relationship
    remove_index :account_contacts, :name => 'unique_account_contact_types'
    remove_index :account_contacts, :name => 'unique_account_contact_type_str'
  
    create_table :title_group, :force => true do |t|
      t.references :account
      t.references :contact
      t.datetime   :deleted_at
      t.timestamps
    end


    create_table :title, :force => true do |t|
      t.references :title_group
      t.string :name
    end
  end

  def down
    add_column :account_contacts, :account_contact_type, :string
    add_index :account_contacts, [:contact_id, :account_id, :account_contact_type], :unique => true, :name => 'unique_account_contact_types'
    add_index :account_contacts, :account_contact_type, :unique => false, :name => 'unique_account_contact_type_str'

    drop_table :title_group
    drop_table :title
  end
end
