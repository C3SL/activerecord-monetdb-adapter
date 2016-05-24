# -*- coding: utf-8 -*-
# Cria uma nova base de dados a cada vez. 
require 'rubygems'
require 'activerecord'
require 'minitest/autorun'

class TestConnection < Minitest::Test
  def test_connection
    ActiveRecord::Base.establish_connection :adapter => "monetdb", :database => "monetdb"
    assert_equal true, true
  end
end
