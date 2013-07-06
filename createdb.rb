require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
	:adapter => "postgresql",
	:database  => "test_shard",
	:schema_search_path => "t1",
	:host => "localhost",
	:username => "test",
	:password => "123456"
)

ActiveRecord::Schema.define do
	create_table :posts do |table|
		table.column :title, :string
		table.column :description, :text
		table.column :torrent, :string
		table.column :download, :string
		table.column :note, :string
		table.column :published, :boolean
	end	
end