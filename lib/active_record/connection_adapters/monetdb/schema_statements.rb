require 'active_record/migration/join_table'
require 'active_support/core_ext/string/access'
require 'digest'

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module MonetDB
      module SchemaStatements
        # Returns a hash of mappings from the abstract data types to the native
        # database types. See TableDefinition#column for details on the recognized
        # abstract data types.
        def native_database_types
          {}
        end

        # Returns the relation names useable to back Active Record models.
        # For most adapters this means all tables and views.
        def data_sources
          tables
        end

        # Checks to see if the data source +name+ exists on the database.
        #
        #   data_source_exists?(:ebooks)
        #
        def data_source_exists?(name)
          data_sources.include?(name.to_s)
        end

        # Checks to see if the table +table_name+ exists on the database.
        #
        #   table_exists?(:developers)
        #
        def table_exists?(table_name)
          tables.include?(table_name.to_s)
        end

        # Returns an array of Column objects for the table specified by +table_name+.
        # See the concrete implementation for details on the expected parameter values.
        def columns(table_name) end

        # Checks to see if a column exists in a given table.
        #
        #   # Check a column exists
        #   column_exists?(:suppliers, :name)
        #
        #   # Check a column exists of a particular type
        #   column_exists?(:suppliers, :name, :string)
        #
        #   # Check a column exists with a specific definition
        #   column_exists?(:suppliers, :name, :string, limit: 100)
        #   column_exists?(:suppliers, :name, :string, default: 'default')
        #   column_exists?(:suppliers, :name, :string, null: false)
        #   column_exists?(:suppliers, :tax, :decimal, precision: 8, scale: 2)
        #
        def column_exists?(table_name, column_name, type = nil, options = {})
          column_name = column_name.to_s
          columns(table_name).any?{ |c| c.name == column_name &&
                                        (!type                     || c.type == type) &&
                                        (!options.key?(:limit)     || c.limit == options[:limit]) &&
                                        (!options.key?(:precision) || c.precision == options[:precision]) &&
                                        (!options.key?(:scale)     || c.scale == options[:scale]) &&
                                        (!options.key?(:default)   || c.default == options[:default]) &&
                                        (!options.key?(:null)      || c.null == options[:null]) }
        end

        # Renames a table.
        #
        #   rename_table('octopuses', 'octopi')
        #
        def rename_table(table_name, new_name)
          raise NotImplementedError, "rename_table is not implemented"
        end

        # Drops a table from the database.
        #
        # [<tt>:force</tt>]
        #   Set to +:cascade+ to drop dependent objects as well.
        #   Defaults to false.
        #
        # Although this command ignores most +options+ and the block if one is given,
        # it can be helpful to provide these in a migration's +change+ method so it can be reverted.
        # In that case, +options+ and the block will be used by create_table.
        def drop_table(table_name, options = {})
          execute "DROP TABLE #{quote_table_name(table_name)}"
        end

        # Adds a new column to the named table.
        # See TableDefinition#column for details of the options you can use.
        def add_column(table_name, column_name, type, options = {})
          at = create_alter_table table_name
          at.add_column(column_name, type, options)
          execute schema_creation.accept at
        end

        # Removes the given columns from the table definition.
        #
        #   remove_columns(:suppliers, :qualification, :experience)
        #
        def remove_columns(table_name, *column_names)
          raise ArgumentError.new("You must specify at least one column name. Example: remove_columns(:people, :first_name)") if column_names.empty?
          column_names.each do |column_name|
            remove_column(table_name, column_name)
          end
        end

        # Removes the column from the table definition.
        #
        #   remove_column(:suppliers, :qualification)
        #
        # The +type+ and +options+ parameters will be ignored if present. It can be helpful
        # to provide these in a migration's +change+ method so it can be reverted.
        # In that case, +type+ and +options+ will be used by add_column.
        def remove_column(table_name, column_name, type = nil, options = {})
          execute "ALTER TABLE #{quote_table_name(table_name)} DROP #{quote_column_name(column_name)}"
        end

        # Changes the column's definition according to the new options.
        # See TableDefinition#column for details of the options you can use.
        #
        #   change_column(:suppliers, :name, :string, limit: 80)
        #   change_column(:accounts, :description, :text)
        #
        def change_column(table_name, column_name, type, options = {})
          raise NotImplementedError, "change_column is not implemented"
        end

        # Sets a new default value for a column:
        #
        #   change_column_default(:suppliers, :qualification, 'new')
        #   change_column_default(:accounts, :authorized, 1)
        #
        # Setting the default to +nil+ effectively drops the default:
        #
        #   change_column_default(:users, :email, nil)
        #
        def change_column_default(table_name, column_name, default)
          raise NotImplementedError, "change_column_default is not implemented"
        end

        # Sets or removes a +NOT NULL+ constraint on a column. The +null+ flag
        # indicates whether the value can be +NULL+. For example
        #
        #   change_column_null(:users, :nickname, false)
        #
        # says nicknames cannot be +NULL+ (adds the constraint), whereas
        #
        #   change_column_null(:users, :nickname, true)
        #
        # allows them to be +NULL+ (drops the constraint).
        #
        # The method accepts an optional fourth argument to replace existing
        # +NULL+s with some other value. Use that one when enabling the
        # constraint if needed, since otherwise those rows would not be valid.
        #
        # Please note the fourth argument does not set a column's default.
        def change_column_null(table_name, column_name, null, default = nil)
          raise NotImplementedError, "change_column_null is not implemented"
        end

        # Renames a column.
        #
        #   rename_column(:suppliers, :description, :name)
        #
        def rename_column(table_name, column_name, new_column_name)
          raise NotImplementedError, "rename_column is not implemented"
        end

        # Adds a new index to the table. +column_name+ can be a single Symbol, or
        # an Array of Symbols.
        #
        # The index will be named after the table and the column name(s), unless
        # you pass <tt>:name</tt> as an option.
        #
        # ====== Creating a simple index
        #
        #   add_index(:suppliers, :name)
        #
        # generates:
        #
        #   CREATE INDEX suppliers_name_index ON suppliers(name)
        #
        # ====== Creating a unique index
        #
        #   add_index(:accounts, [:branch_id, :party_id], unique: true)
        #
        # generates:
        #
        #   CREATE UNIQUE INDEX accounts_branch_id_party_id_index ON accounts(branch_id, party_id)
        #
        # ====== Creating a named index
        #
        #   add_index(:accounts, [:branch_id, :party_id], unique: true, name: 'by_branch_party')
        #
        # generates:
        #
        #  CREATE UNIQUE INDEX by_branch_party ON accounts(branch_id, party_id)
        #
        # ====== Creating an index with specific key length
        #
        #   add_index(:accounts, :name, name: 'by_name', length: 10)
        #
        # generates:
        #
        #   CREATE INDEX by_name ON accounts(name(10))
        #
        #   add_index(:accounts, [:name, :surname], name: 'by_name_surname', length: {name: 10, surname: 15})
        #
        # generates:
        #
        #   CREATE INDEX by_name_surname ON accounts(name(10), surname(15))
        #
        # Note: SQLite doesn't support index length.
        #
        # ====== Creating an index with a sort order (desc or asc, asc is the default)
        #
        #   add_index(:accounts, [:branch_id, :party_id, :surname], order: {branch_id: :desc, party_id: :asc})
        #
        # generates:
        #
        #   CREATE INDEX by_branch_desc_party ON accounts(branch_id DESC, party_id ASC, surname)
        #
        # Note: MySQL doesn't yet support index order (it accepts the syntax but ignores it).
        #
        # ====== Creating a partial index
        #
        #   add_index(:accounts, [:branch_id, :party_id], unique: true, where: "active")
        #
        # generates:
        #
        #   CREATE UNIQUE INDEX index_accounts_on_branch_id_and_party_id ON accounts(branch_id, party_id) WHERE active
        #
        # Note: Partial indexes are only supported for PostgreSQL and SQLite 3.8.0+.
        #
        # ====== Creating an index with a specific method
        #
        #   add_index(:developers, :name, using: 'btree')
        #
        # generates:
        #
        #   CREATE INDEX index_developers_on_name ON developers USING btree (name) -- PostgreSQL
        #   CREATE INDEX index_developers_on_name USING btree ON developers (name) -- MySQL
        #
        # Note: only supported by PostgreSQL and MySQL
        #
        # ====== Creating an index with a specific type
        #
        #   add_index(:developers, :name, type: :fulltext)
        #
        # generates:
        #
        #   CREATE FULLTEXT INDEX index_developers_on_name ON developers (name) -- MySQL
        #
        # Note: only supported by MySQL. Supported: <tt>:fulltext</tt> and <tt>:spatial</tt> on MyISAM tables.
        def add_index(table_name, column_name, options = {})
          index_name, index_type, index_columns, index_options = add_index_options(table_name, column_name, options)
          execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} (#{index_columns})#{index_options}"
        end

        # Removes the given index from the table.
        #
        # Removes the +index_accounts_on_column+ in the +accounts+ table.
        #
        #   remove_index :accounts, :column
        #
        # Removes the index named +index_accounts_on_branch_id+ in the +accounts+ table.
        #
        #   remove_index :accounts, column: :branch_id
        #
        # Removes the index named +index_accounts_on_branch_id_and_party_id+ in the +accounts+ table.
        #
        #   remove_index :accounts, column: [:branch_id, :party_id]
        #
        # Removes the index named +by_branch_party+ in the +accounts+ table.
        #
        #   remove_index :accounts, name: :by_branch_party
        #
        def remove_index(table_name, options = {})
          remove_index!(table_name, index_name_for_remove(table_name, options))
        end

        def remove_index!(table_name, index_name) #:nodoc:
          execute "DROP INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)}"
        end

        # Renames an index.
        #
        # Rename the +index_people_on_last_name+ index to +index_users_on_last_name+:
        #
        #   rename_index :people, 'index_people_on_last_name', 'index_users_on_last_name'
        #
        def rename_index(table_name, old_name, new_name)
          validate_index_length!(table_name, new_name)

          # this is a naive implementation; some DBs may support this more efficiently (Postgres, for instance)
          old_index_def = indexes(table_name).detect { |i| i.name == old_name }
          return unless old_index_def
          add_index(table_name, old_index_def.columns, name: new_name, unique: old_index_def.unique)
          remove_index(table_name, name: old_name)
        end

        def index_name(table_name, options) #:nodoc:
          if Hash === options
            if options[:column]
              "index_#{table_name}_on_#{Array(options[:column]) * '_and_'}"
            elsif options[:name]
              options[:name]
            else
              raise ArgumentError, "You must specify the index name"
            end
          else
            index_name(table_name, :column => options)
          end
        end

        # Verifies the existence of an index with a given name.
        #
        # The default argument is returned if the underlying implementation does not define the indexes method,
        # as there's no way to determine the correct answer in that case.
        def index_name_exists?(table_name, index_name, default)
          return default unless respond_to?(:indexes)
          index_name = index_name.to_s
          indexes(table_name).detect { |i| i.name == index_name }
        end

        # Adds a reference. The reference column is an integer by default,
        # the <tt>:type</tt> option can be used to specify a different type.
        # Optionally adds a +_type+ column, if <tt>:polymorphic</tt> option is provided.
        # <tt>add_reference</tt> and <tt>add_belongs_to</tt> are acceptable.
        #
        # The +options+ hash can include the following keys:
        # [<tt>:type</tt>]
        #   The reference column type. Defaults to +:integer+.
        # [<tt>:index</tt>]
        #   Add an appropriate index. Defaults to false.
        # [<tt>:foreign_key</tt>]
        #   Add an appropriate foreign key. Defaults to false.
        # [<tt>:polymorphic</tt>]
        #   Wether an additional +_type+ column should be added. Defaults to false.
        #
        # ====== Create a user_id integer column
        #
        #   add_reference(:products, :user)
        #
        # ====== Create a user_id string column
        #
        #   add_reference(:products, :user, type: :string)
        #
        # ====== Create supplier_id, supplier_type columns and appropriate index
        #
        #   add_reference(:products, :supplier, polymorphic: true, index: true)
        #
        def add_reference(table_name, ref_name, options = {})
          polymorphic = options.delete(:polymorphic)
          index_options = options.delete(:index)
          type = options.delete(:type) || :integer
          foreign_key_options = options.delete(:foreign_key)

          if polymorphic && foreign_key_options
            raise ArgumentError, "Cannot add a foreign key to a polymorphic relation"
          end

          add_column(table_name, "#{ref_name}_id", type, options)
          add_column(table_name, "#{ref_name}_type", :string, polymorphic.is_a?(Hash) ? polymorphic : options) if polymorphic
          add_index(table_name, polymorphic ? %w[type id].map{ |t| "#{ref_name}_#{t}" } : "#{ref_name}_id", index_options.is_a?(Hash) ? index_options : {}) if index_options
          if foreign_key_options
            to_table = Base.pluralize_table_names ? ref_name.to_s.pluralize : ref_name
            add_foreign_key(table_name, to_table, foreign_key_options.is_a?(Hash) ? foreign_key_options : {})
          end
        end
        alias :add_belongs_to :add_reference

        # Removes the reference(s). Also removes a +type+ column if one exists.
        # <tt>remove_reference</tt>, <tt>remove_references</tt> and <tt>remove_belongs_to</tt> are acceptable.
        #
        # ====== Remove the reference
        #
        #   remove_reference(:products, :user, index: true)
        #
        # ====== Remove polymorphic reference
        #
        #   remove_reference(:products, :supplier, polymorphic: true)
        #
        # ====== Remove the reference with a foreign key
        #
        #   remove_reference(:products, :user, index: true, foreign_key: true)
        #
        def remove_reference(table_name, ref_name, options = {})
          if options[:foreign_key]
            to_table = Base.pluralize_table_names ? ref_name.to_s.pluralize : ref_name
            remove_foreign_key(table_name, to_table)
          end

          remove_column(table_name, "#{ref_name}_id")
          remove_column(table_name, "#{ref_name}_type") if options[:polymorphic]
        end
        alias :remove_belongs_to :remove_reference

        # Returns an array of foreign keys for the given table.
        # The foreign keys are represented as +ForeignKeyDefinition+ objects.
        def foreign_keys(table_name)
          raise NotImplementedError, "foreign_keys is not implemented"
        end

        # Adds a new foreign key. +from_table+ is the table with the key column,
        # +to_table+ contains the referenced primary key.
        #
        # The foreign key will be named after the following pattern: <tt>fk_rails_<identifier></tt>.
        # +identifier+ is a 10 character long string which is deterministically generated from the
        # +from_table+ and +column+. A custom name can be specified with the <tt>:name</tt> option.
        #
        # ====== Creating a simple foreign key
        #
        #   add_foreign_key :articles, :authors
        #
        # generates:
        #
        #   ALTER TABLE "articles" ADD CONSTRAINT articles_author_id_fk FOREIGN KEY ("author_id") REFERENCES "authors" ("id")
        #
        # ====== Creating a foreign key on a specific column
        #
        #   add_foreign_key :articles, :users, column: :author_id, primary_key: :lng_id
        #
        # generates:
        #
        #   ALTER TABLE "articles" ADD CONSTRAINT fk_rails_58ca3d3a82 FOREIGN KEY ("author_id") REFERENCES "users" ("lng_id")
        #
        # ====== Creating a cascading foreign key
        #
        #   add_foreign_key :articles, :authors, on_delete: :cascade
        #
        # generates:
        #
        #   ALTER TABLE "articles" ADD CONSTRAINT articles_author_id_fk FOREIGN KEY ("author_id") REFERENCES "authors" ("id") ON DELETE CASCADE
        #
        # The +options+ hash can include the following keys:
        # [<tt>:column</tt>]
        #   The foreign key column name on +from_table+. Defaults to <tt>to_table.singularize + "_id"</tt>
        # [<tt>:primary_key</tt>]
        #   The primary key column name on +to_table+. Defaults to +id+.
        # [<tt>:name</tt>]
        #   The constraint name. Defaults to <tt>fk_rails_<identifier></tt>.
        # [<tt>:on_delete</tt>]
        #   Action that happens <tt>ON DELETE</tt>. Valid values are +:nullify+, +:cascade:+ and +:restrict+
        # [<tt>:on_update</tt>]
        #   Action that happens <tt>ON UPDATE</tt>. Valid values are +:nullify+, +:cascade:+ and +:restrict+
        def add_foreign_key(from_table, to_table, options = {})
          return unless supports_foreign_keys?

          options[:column] ||= foreign_key_column_for(to_table)

          options = {
            column: options[:column],
            primary_key: options[:primary_key],
            name: foreign_key_name(from_table, options),
            on_delete: options[:on_delete],
            on_update: options[:on_update]
          }
          at = create_alter_table from_table
          at.add_foreign_key to_table, options

          execute schema_creation.accept(at)
        end

        # Removes the given foreign key from the table.
        #
        # Removes the foreign key on +accounts.branch_id+.
        #
        #   remove_foreign_key :accounts, :branches
        #
        # Removes the foreign key on +accounts.owner_id+.
        #
        #   remove_foreign_key :accounts, column: :owner_id
        #
        # Removes the foreign key named +special_fk_name+ on the +accounts+ table.
        #
        #   remove_foreign_key :accounts, name: :special_fk_name
        #
        def remove_foreign_key(from_table, options_or_to_table = {})
          return unless supports_foreign_keys?

          if options_or_to_table.is_a?(Hash)
            options = options_or_to_table
          else
            options = { column: foreign_key_column_for(options_or_to_table) }
          end

          fk_name_to_delete = options.fetch(:name) do
            fk_to_delete = foreign_keys(from_table).detect {|fk| fk.column == options[:column].to_s }

            if fk_to_delete
              fk_to_delete.name
            else
              raise ArgumentError, "Table '#{from_table}' has no foreign key on column '#{options[:column]}'"
            end
          end

          at = create_alter_table from_table
          at.drop_foreign_key fk_name_to_delete

          execute schema_creation.accept(at)
        end

        def foreign_key_column_for(table_name) # :nodoc:
          prefix = Base.table_name_prefix
          suffix = Base.table_name_suffix
          name = table_name.to_s =~ /#{prefix}(.+)#{suffix}/ ? $1 : table_name.to_s
          "#{name.singularize}_id"
        end

        def type_to_sql(type, limit = nil, precision = nil, scale = nil) #:nodoc:
          if native = native_database_types[type.to_sym]
            column_type_sql = (native.is_a?(Hash) ? native[:name] : native).dup

            if type == :decimal # ignore limit, use precision and scale
              scale ||= native[:scale]

              if precision ||= native[:precision]
                if scale
                  column_type_sql << "(#{precision},#{scale})"
                else
                  column_type_sql << "(#{precision})"
                end
              elsif scale
                raise ArgumentError, "Error adding decimal column: precision cannot be empty if scale is specified"
              end

            elsif (type != :primary_key) && (limit ||= native.is_a?(Hash) && native[:limit])
              column_type_sql << "(#{limit})"
            end

            column_type_sql
          else
            type.to_s
          end
        end

        # Given a set of columns and an ORDER BY clause, returns the columns for a SELECT DISTINCT.
        # PostgreSQL, MySQL, and Oracle overrides this for custom DISTINCT syntax - they
        # require the order columns appear in the SELECT.
        #
        #   columns_for_distinct("posts.id", ["posts.created_at desc"])
        #
        def columns_for_distinct(columns, orders) # :nodoc:
          columns
        end

        protected
          # Overridden by the MySQL adapter for supporting index lengths
          def quoted_columns_for_index(column_names, options = {})
            option_strings = Hash[column_names.map {|name| [name, '']}]

            # add index sort order if supported
            if supports_index_sort_order?
              option_strings = add_index_sort_order(option_strings, column_names, options)
            end

            column_names.map {|name| quote_column_name(name) + option_strings[name]}
          end
      end
    end
  end
end
