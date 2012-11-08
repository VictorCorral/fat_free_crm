require 'fileutils'
require 'json'
require 'hasherize_csv'

def loadActiveRecord( items )
    failed_instances = []
    num_inserts = 0
    ActiveRecord::Base.transaction do 
       items.each do |a|
          res = a.save 
          if res 
           num_inserts = num_inserts + 1
          else 
           failed_instances << {:object => a.inspect, :errors => a.errors.inspect}
          end
       end
    end

    Rails.logger.info("Import complete; #{num_inserts}")
    if failed_instances.count > 0
      Rails.logger.info("Import failed for following: #{failed_instances.join('\n')}")
    end
end

def load_field_descriptions jsonfilename, csvfilename, sf_type
	f = File.new(jsonfilename)
	json = f.read

	g = File.new(csvfilename)
	csv = HasherizeCsv::Csv.new(g, :separator => "\r")

	h = JSON.parse(json)

	items = []
	csv.each do |record|
	#  puts record.inspect
	  location = record["Location"].strip
	#  puts "record location: #{location}"
	  details = h[sf_type][ location ] 
	  if details
	     items << details.invert.select {|item| item["label"].strip == record["SF Tab"].strip}.collect{|k,v| [v.downcase, k.merge({"location" => location, "keep" => (record['Suggested Action'] == 'Keep') })]}.flatten
	  else 
	   puts "Warning: Couldn't find info for location #{record["Location"]} (field #{record["SF Tab"]} / #{record["Suggested Action"]} )"
	  end
	end

	result = Hash[items]
	puts result.inspect
	return result
end

def load_field_metadata klass
        custom_field_metadata = load_field_descriptions ENV['SF_JSON_METADATA'], ENV['SF_TABLE_METADATA'], klass.to_s.downcase if (ENV['SF_JSON_METADATA'] and ENV['SF_TABLE_METADATA']) 

        custom_field_metadata.each do |field_name, metadata|
	  field_group = FieldGroup.where(:label => metadata['location'], :klass_name => klass.to_s).first

	  if(!field_group)
             field_group = FieldGroup.new()
	     field_group.label = metadata['location']
	     field_group.klass_name = klass.to_s
	     field_group.save!
	  end 

	  f = CustomField.where(:label => metadata["label"], :field_group_id => field_group.id).first
	  if !f && !klass.columns.map(&:name).include?(field_name) && metadata["keep"]
		  f = CustomField.new( 
		      :name => (field_name ),
		      :field_group => field_group,
		      :label => metadata["label"],
		      :klass_name => klass.to_s,
		      :as => case metadata["datatype"]
			      when 'string'
				 'string'
			      when 'multipicklist'
				 'check_boxes'
			      when 'date'
				 'date'
			      when 'textarea'
				 'text'
			      when 'currency'
				 'decimal'
			      when 'double'
				 'float'
			      when 'boolean'
				 'boolean'
			      when 'picklist'
				 'select'
			      when 'phone'
				 'tel'
			      when 'url'
				 'url'
			      else
				 puts "Warning: unknown custom field type #{metadata['datatype']}; choosing string" 
				 'string'
			      end,
		      :collection => (metadata["picklist"]),
		      :required => metadata["required"],
		      :hint => metadata["hint"],
#		      :disabled => !metadata["editable"],
		      )  
		  puts "Trying to save #{f.inspect}"
		  f.save!
           else 
	      puts "Warning: ignored field #{field_name} / #{metadata.inspect} / #{f.inspect}"
           end
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
     
    desc "Load account metadata from a salesforce csv"
    task :account_custom_fields => :environment do
       load_field_metadata Account 
    end

    desc "Load accounts from a salesforce csv"
    task :accounts => :environment do
	if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
	end

	salesforce_accounts = Salesforce.connection.send(:select, ('SELECT "good_accounts".* FROM "good_accounts"'))
	Account.observers.disable :all do #Otherwise 'recent activity' goes bananas
                accounts = []
                i = 0
		salesforce_accounts.each do |h| 
                     account_attr = {
	             :salesforce_id => h["id"],
                     :salesforce_parent_id => h["parentid"],
		     :user_id => User.first.id,
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

		    }
		    account_attr.merge!(h.select{|k,v| (!!(k =~ /\w*__c/) \
		                            and k != "services_products_subscriptions__c"  \
		                            and k != "trading_platforms__c" \
		                            and k != "products__c" \
					    and Account.columns.map(&:name).include?(k)) 
		                      })
		    
		    array_fields = h.select{|k,v| (k == "services_products_subscriptions__c"  \
		                            and k == "trading_platforms__c" \
		                            and k == "products__c")}
					   
		    array_fields.each{|k,v| array_fields[k] = v.split(";").collect {|i| i.strip}}
                           

		   accounts << Account.new(account_attr)

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

    desc "Load account metadata from a salesforce csv"
    task :contact_custom_fields => :environment do
       load_field_metadata Contact 
    end

    desc "Load contacts from a salesforce csv"
    task :contacts => :environment do
	if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
	end

	salesforce_contacts = Salesforce.connection.send(:select, ('SELECT "good_contacts".* FROM "good_contacts" '))
	Contact.observers.disable :all do #Otherwise 'recent activity' goes bananas
                contacts = []
                i = 0
		salesforce_contacts.each do |h| 
		  contact_attr = {
                     :salesforce_id => h["id"],
                     :account => Account.find_by_salesforce_id(h["accountid"]),
		     :user_id => User.first.id,
		     :first_name => h["firstname"] || h["contact_name__c"].split('-')[0],
		     :last_name => h["lastname"],
		     :blog => h["website"],
		     :phone => h["phone"],
		     :mobile => h["mobilephone"],
		     :fax => h["fax"],
		     :title => h["title"],
		     :department => h["department"],
		     :email => h["email"],
		     :business_address_attributes => { 
			:street1 => h["mailingstreet"],
			:city => h["mailingcity"],
			:state => h["mailingstate"],
			:zipcode => h["mailingpostalcode"],
			:country => h["mailingcountry"],
			:address_type => 'Business', #shouldn't need to specify that... but we do. probably a activerecord bug with ":conditions" on mass assignment
		      },
                     :alternate_address_attributes => { 
			:street1 => h["otherstreet"],
			:city => h["othercity"],
			:state => h["otherstate"],
			:zipcode => h["otherpostalcode"],
			:country => h["othercountry"],
			:address_type => 'Alternate', #shouldn't need to specify that... but we do. probably a activerecord bug with ":conditions" on mass assignment
		      },
		    }
		    
		    contact_attr.merge!(h.select{|k,v| (!!(k =~ /\w*__c/) \
                                            and !(k =~ /title[0-9]__c/) \
                                            and !!(k =~ /homephone/) \
					    and Contact.columns.map(&:name).include?(k)) 
		                      })
		    
		    array_fields = h.select{|k,v| (!!(k =~ /title[0-9]__c/) and v) }

		    array_fields.each{|k,v| array_fields[k] = v.split(";").collect {|i| i.strip}}
                    
		    contact_attr.merge!(array_fields) 

	         #puts contact_attr.inspect	
		 contacts << Contact.new(contact_attr)
                 i = i + 1; if i % 1000 == 1
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
