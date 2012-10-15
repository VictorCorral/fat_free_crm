class AddAccountIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :parent_account_id, :integer	
  end
end
