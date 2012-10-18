require 'hasherize_csv' 
require 'fileutils'

def loadAccounts( accounts )
    failed_instances = []
    num_inserts = 0
    ActiveRecord::Base.transaction do 
       accounts.each do |a|
          res = a.save 
          if res 
           num_inserts = num_inserts + 1
          else 
           failed_instances << a 
          end
       end
    end

    Rails.logger.info("Import complete; #{num_inserts}")
    if failed_instances.count > 0
      Rails.logger.info("Import failed for following: #{failed_instances.join('\n')}")
    end
end

namespace :load_csv do
    desc "Associated accounts with each other based on Salesforceid"
    task :associate_accounts => :environment do 
       children = Account.where("'salesforce_parent_id' IS NOT NULL")
       children.each do |child|
         child.parent_account = Account.find_by_salesforce_id(child.salesforce_parent_id)
         child.save
       end
    end

    desc "Load accounts from a salesforce csv"
    task :accounts => :environment do
	if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
	end

        filename = ENV['CSV_FILE'] || File.join(File.expand_path(File.dirname(__FILE__)),"accounts.csv")       
	f = File.new filename
        csv = HasherizeCsv::Csv.new(f, HasherizeCsv::DefaultOpts::SALESFORCE)
	Account.observers.disable :all do #Otherwise 'recent activity' goes bananas
                accounts = []
                i = 0
		csv.each do |h| 
		   accounts << Account.new(
                     :salesforce_id => h["Id"],
                     :salesforce_parent_id => h["ParentId"],
		     :user => User.first,
		     :name => h["Name"],
		     :website => h["Website"],
		     :phone => h["Phone"],
		     :fax => h["Fax"],
		     :category => h["Type"].downcase.gsub(' ','_').gsub('-','_'),
		     :billing_address_attributes => { 
			:street1 => h["BillingStreet"],
			:city => h["BillingCity"],
			:state => h["BillingState"],
			:zipcode => h["BillingPostalCode"],
			:country => h["BillingCountry"],
			:address_type => 'Billing', #shouldn't need to specify that... but we do. Probably a activerecord bug with ":conditions" on mass assignment
		      },
		     :shipping_address_attributes => {
			:street1 => h["ShippingStreet"],
			:city => h["ShippingCity"],
			:state => h["ShippingState"],
			:zipcode => h["ShippingPostalCode"],
			:country => h["ShippingCountry"],
			:address_type => 'Shipping', #shouldn't need to specify that... but we do. Probably a activerecord bug with ":conditions" on mass assignment
		      },
		   )
                 i = i + 1; if i % 1000 == 0
                  Rails.logger.info("#{i}: begin db load")
                  loadAccounts(accounts)
                  accounts = []
                 end
               end
               Rails.logger.info("#{i}: begin db load")
               loadAccounts(accounts)
              
	end
    end
end
