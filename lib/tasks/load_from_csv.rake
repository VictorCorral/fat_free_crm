require 'fileutils'

def loadActiveRecord( items )
    failed_instances = []
    num_inserts = 0
    ActiveRecord::Base.transaction do 
       items.each do |a|
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

	salesforce_accounts = Salesforce.connection.send(:select, ('SELECT "account".* FROM "account"'))
	Account.observers.disable :all do #Otherwise 'recent activity' goes bananas
                accounts = []
                i = 0
		salesforce_accounts.each do |h| 
		   accounts << Account.new(
                     :salesforce_id => h["id"],
                     :salesforce_parent_id => h["parentid"],
		     :user => User.first,
		     :name => h["name"],
		     :website => h["website"],
		     :phone => h["phone"],
		     :fax => h["fax"],
		     :category => ( h["type"].downcase.gsub(' ','_').gsub('-','_') if h["type"] ),
		     :billing_address_attributes => { 
			:street1 => h["billingstreet"],
			:city => h["billingcity"],
			:state => h["billingstate"],
			:zipcode => h["billingpostalcode"],
			:country => h["billingcountry"],
			:address_type => 'Billing', #shouldn't need to specify that... but we do. probably a activerecord bug with ":conditions" on mass assignment
		      },
		     :shipping_address_attributes => {
			:street1 => h["shippingstreet"],
			:city => h["shippingcity"],
			:state => h["shippingstate"],
			:zipcode => h["shippingpostalcode"],
			:country => h["shippingcountry"],
			:address_type => 'Shipping', #shouldn't need to specify that... but we do. probably a activerecord bug with ":conditions" on mass assignment
		      },
		   )
                 i = i + 1; if i % 1000 == 0
                  Rails.logger.info("#{i}: begin db load")
                  loadActiveRecord(accounts)
                  accounts = []
                 end
               end
               Rails.logger.info("#{i}: begin db load")
               loadActiveRecord(accounts)
	end
    end


    desc "Load contacts from a salesforce csv"
    task :contacts => :environment do
	if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
	end

	salesforce_contacts = Salesforce.connection.send(:select, ('SELECT "contact".* FROM "contact"'))
	Contact.observers.disable :all do #Otherwise 'recent activity' goes bananas
                contacts = []
                i = 0
		salesforce_contacts.each do |h| 
		   contacts << Contact.new(
                     :salesforce_id => h["id"],
                     :account => Account.find_by_salesforce_id(h["accountid"]),
		     :user => User.first,
		     :first_name => h["firstname"],
		     :last_name => h["lastname"],
		     :blog => h["website"],
		     :phone => h["phone"],
		     :mobile => h["mobilephone"],
		     :fax => h["fax"],
		     :business_address_attributes => { 
			:street1 => h["mailingstreet"],
			:city => h["mailingcity"],
			:state => h["mailingstate"],
			:zipcode => h["mailingpostalcode"],
			:country => h["mailingcountry"],
			:address_type => 'Billing', #shouldn't need to specify that... but we do. probably a activerecord bug with ":conditions" on mass assignment
		      },
		)
                 i = i + 1; if i % 1000 == 0
                  Rails.logger.info("#{i}: begin db load")
                  loadActiveRecord(contacts)
                  contacts = []
                 end
               end
               Rails.logger.info("#{i}: begin db load")
               loadActiveRecord(contacts)
	end
    end
end
