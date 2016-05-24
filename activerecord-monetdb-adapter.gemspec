Gem::Specification.new do |s|
   s.required_ruby_version = '>= 2.1.0'
   s.name = %q{activerecord-monetdb-adapter}
   s.version = "0.2"
   s.date = %q{2016-05-24}
   s.authors = ["G Modena", "J V Risso"]
   s.email = [ "gm@cwi.nl", "jvtr12@c3sl.ufpr.br" ]
   s.summary = %q{ActiveRecord Connector for MonetDB}
   s.homepage = [ "http://monetdb.cwi.nl/", "https://gitlab.c3sl.ufpr.br/" ]
   s.description = %q{ActiveRecord Connector for MonetDB built on top of the pure Ruby database driver}
   s.files = [ "lib/active_record/connection_adapters/monetdb_adapter.rb" ]
   s.has_rdoc = true
   s.require_path = 'lib'
   s.add_dependency(%q<activerecord>, [">= 2.3.2"])
   s.add_dependency(%q<ruby-monetdb-sql>, [">= 0.1"])
   # placeholder project to avoid warning about not having a rubyforge_project
   s.rubyforge_project = "nowarning"
end
