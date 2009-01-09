class CreateOpportunities < ActiveRecord::Migration
  def self.up
    create_table :opportunities, :force => true do |t|
      t.string      :uuid,     :limit => 36
      t.references  :user
      t.references  :campaign
      t.integer     :assigned_to
      t.string      :name,     :limit => 64, :null => false, :default => ""
      t.string      :access,   :limit => 8, :default => "Private" # %w(Private Public Shared)
      t.string      :source,   :limit => 32
      t.string      :stage,    :limit => 32
      t.integer     :probability
      t.decimal     :amount,   :precision => 12, :scale => 2
      t.decimal     :discount, :precision => 12, :scale => 2
      t.date        :closes_on
      t.text        :notes
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :opportunities, [ :user_id, :deleted_at ], :unique => true
    add_index :opportunities, :uuid

    if adapter_name.downcase == "mysql"
      if select_value("select version()").to_i >= 5
        execute("CREATE TRIGGER opportunities_uuid BEFORE INSERT ON opportunities FOR EACH ROW SET NEW.uuid = UUID()")
      end
    end
  end

  def self.down
    drop_table :opportunities
  end
end
