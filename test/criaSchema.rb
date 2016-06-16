# -*- coding: utf-8 -*-

require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection :adapter => "monetdb",
                                        :database => "testdb",
                                        :username => "monetdb",
                                        :password => "monetdb"

ActiveRecord::Base.connection.create_table :pessoas do |t|
  t.string   :last_name
  t.string   :first_name
  t.string   :address
  t.integer  :address_number
  t.string   :city
end
