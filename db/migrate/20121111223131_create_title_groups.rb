class CreateTitleGroups < ActiveRecord::Migration
  def up
   #Get rid of relationship info on direct account_contact relationships
    remove_index :account_contacts, :name => 'unique_account_contact_types' if index_name_exists? :account_contacts, 'unique_account_contact_types', false
    remove_index :account_contacts, :name => 'account_contact_types' if index_name_exists? :account_contacts, 'account_contact_types', false
    remove_index :account_contacts, :name => 'unique_account_contact_type_str' if index_name_exists? :account_contacts, 'unique_account_contact_type_str', false
    remove_column :account_contacts, :account_contact_type

    create_table :title_groups, :force => true do |t|
      t.references :contact
      t.datetime   :deleted_at
      t.timestamps
    end

    create_table :accounts_title_groups, :force => true do |t|
      t.references :account
      t.references :title_group
    end

    create_table :titles, :force => true do |t|
      t.string :name
    end

    create_table :title_groups_titles, :force => true do |t|
      t.references :title
      t.references :title_group
    end

     
    [
     "ACAT Contact",
     "AMA Services",
     "Banking Contact",
     "Buy-Ins Contact",
     "CCO",
     "CEO",
     "CFO",
     "Compliance Contact",
     "Conversion Contact",
     "Corp Actions Contact",
     "Customer Service",
     "Dealer Cashiering Contact",
     "Dividends Contact",
     "DK Notices",
     "Domestic Settlements Contact",
     "Emergency",
     "Fixed Income Operations",
     "FTP Contact",
     "Institutional",
     "International Settlements Contact",
     "IRA Contact",
     "IT Support",
     "Margins Contact",
     "Mutual Fund Contact",
     "New Accts Contact",
     "Office Manager",
     "Office Owner",
     "Operations Contact",
     "Operations Manager",
     "P&S Contact",
     "President",
     "Primary Relationship Contact",
     "Risk Contact",
     "Settlements Contact",
     "Stock Loan Contact",
     "Stock Receipts Contact",
     "Tax",
     "Technology Contact",
     "Trading Contact",
     "Upload Contact",
     "Authorized Signer",
     "Correspondent Level",
     "Undefined Title"
    ].each do |title|
      Title.create!(:name => title)
    end

    add_index :titles, :name, :unique => true
  end

  def down
    add_column :account_contacts, :account_contact_type, :string
    remove_index :titles, :name

    drop_table :title_groups
    drop_table :titles
  end
end
