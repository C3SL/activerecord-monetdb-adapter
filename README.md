## How to setup

git clone git@gitlab.c3sl.ufpr.br:simcaq/monetdb-sql.git

cd monetdb-sql

make

gem install monetdb-sql-1.0.gem

git clone git@gitlab.c3sl.ufpr.br:simcaq/activerecord-monetdb-adapter.git

cd activerecord-monetdb-adapter

gem build activerecord-monetdb-adapter.gemspec

gem install activerecord-monetdb-adapter-0.2.gem

Then, you can run the tests provided in the tests directory.

For the changes to be available to the Rails application, the ActiveRecord adapter needs
to be rebuilt and reinstalled by issuing the gem build and install commands above.

## MonetDB's internal methods (can be used to retrieve primary keys, foreign keys, columns, tables)

http://dev.monetdb.org/hg/MonetDB/file/tip/clients/mapiclient/dump.c