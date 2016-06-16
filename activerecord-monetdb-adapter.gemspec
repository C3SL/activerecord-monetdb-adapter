Gem::Specification.new do |spec|
   spec.required_ruby_version = '>= 2.1.0'
   spec.name = %q{activerecord-monetdb-adapter}
   spec.version = "0.2"
   spec.date = %q{2016-05-24}
   spec.authors = [ 'G Modena', 'J V Risso' ]
   spec.email = [ "gm@cwi.nl", "jvtr12@c3sl.ufpr.br" ]
   spec.summary = %q{ActiveRecord Connector for MonetDB}
   spec.homepage = 'http://monetdb.cwi.nl/'
   spec.description = %q{ActiveRecord Connector for MonetDB built on top of the pure Ruby database driver}
   spec.files = [ "lib/active_record/connection_adapters/monetdb_adapter.rb", "lib/active_record/connection_adapters/monetdb/column.rb",
    "lib/active_record/connection_adapters/monetdb/column.rb", "lib/active_record/connection_adapters/monetdb/database_statements.rb",
    "lib/active_record/connection_adapters/monetdb/quoting.rb", "lib/active_record/connection_adapters/monetdb/schema_creation.rb",
    "lib/active_record/connection_adapters/monetdb/schema_definitions.rb", "lib/active_record/connection_adapters/monetdb/schema_statements.rb"]
   spec.has_rdoc = true
   spec.require_path = 'lib'
   #spec.add_dependency(%q<activerecord>, [">= 4.0.0"])
   spec.add_runtime_dependency('activerecord', '~> 4.0', '>= 4.0.0')
   spec.add_runtime_dependency('monetdb-sql', '~> 1.0', '>= 1.0')
   #spec.add_dependency(%q<ruby-monetdb-sql>, [">= 1.0"])
   # placeholder project to avoid warning about not having a rubyforge_project
   spec.rubyforge_project = "nowarning"
end
