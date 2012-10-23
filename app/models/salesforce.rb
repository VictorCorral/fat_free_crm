class Salesforce < ActiveRecord::Base
   establish_connection "salesforce"
   self.table_name = "account"
 
end
