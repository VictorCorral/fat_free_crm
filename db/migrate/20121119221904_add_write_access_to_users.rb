class AddWriteAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :write_access, :boolean, :default => false
  end
end
