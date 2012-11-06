class RemoveDefaultValueAndClearSettings < ActiveRecord::Migration
  def up
    remove_column :settings, :default_value
  
    # Truncate settings table
    adapter_name = connection.adapter_name.downcase
    if adapter_name == "sqlite"
      execute("DELETE FROM settings")
    elsif adapter_name == "sqlserver" or adapter_name == "mssql"
      execute("TRUNCATE TABLE settings")
    else # mysql and postgres
      execute("TRUNCATE settings")
    end
  end

  def down
    add_column :settings, :default_value, :text
  end
end
