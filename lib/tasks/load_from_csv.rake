require 'hasherize_csv' 
require 'fileutils'

namespace :load_csv do
    desc "Load accounts from a salesforce csv"
    task :accounts => :environment do
	if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
	end

        filename = ENV['CSV_FILE'] || File.join(File.expand_path(File.dirname(__FILE__)),"accounts.csv")       
	f = File.new filename
        csv = HasherizeCsv::Csv.new(f, HasherizeCsv::DefaultOpts::SALESFORCE)
	Account.observers.disable :all do #Otherwise 'recent activity' goes bananas
		csv.each do |h| 
		   a = Account.new(
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
		   success = a.save
		   if !success
		     Rails.logger.error("Couldn't save #{a.inspect}:")
		     Rails.logger.error(a.errors.full_messages.join("\n"))
		   end
		end
	end
    end
end
