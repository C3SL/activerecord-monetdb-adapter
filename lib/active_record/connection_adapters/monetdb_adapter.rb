require "active_record/connection_adapters/abstract_adapter"
require "active_record/connection_adapters/statement_pool"
require "MonetDB"

module ActiveRecord
  module ConnectionHandling
    # Establishes a connection to the database that's used by all Active Record objects.
    def monetdb_connection(config)
      config = config.symbolize_keys

      client = MonetDB.new(config)
      config[:user] = config.delete[:username] || "monetdb"
      config[:passwd] = config.delete[:password] if config[:password]
      config[:db_name] = config.delete[:database]
      config[:auth_type] = config[:auth_type] || "SHA1"

      begin
        client.connect(config)
      rescue MonetDBConnectionError => error
        if error.message.include?("no such database")
          raise ActiveRecord::NoDatabaseError.new(error.message, error)
        else
          raise
        end
      end

      ConnectionAdapters::MonetDBAdapter.new(client, logger, options, config)
    end
  end

  module ConnectionAdapters
    class MonetDBAdapter < AbstractAdapter
      ADAPTER_NAME = 'MonetDB'.freeze

      # Initializes a MonetDB adapter
      def initialize(connection, logger, connection_parameters, config)
        super(connection, logger)
      end

      def valid_type?
      end

      def schema_creation
        SchemaCreation.new self
      end

      def supports_migrations?
        true
      end

      def supports_primary_key?
        true
      end

      def supports_ddl_transactions?
        true
      end

      def supports_bulk_alter?
        true
      end

      def supports_savepoints?
        true
      end

      def supports_index_sort_order?
      end

      def supports_partial_index?
      end

      def supports_explain?
      end

      def supports_transaction_isolation?
      end

      def supports_extensions?
      end

      def supports_indexes_in_create?
      end

      def supports_foreign_keys?
      end

      def supports_views?
      end

      # This is meant to be implemented by the adapters that support extensions
      def disable_extension(name)
      end

      # This is meant to be implemented by the adapters that support extensions
      def enable_extension(name)
      end

      # A list of extensions, to be filled in by adapters that support them.
      def extensions
        []
      end

      # A list of index algorithms, to be filled by adapters that support them.
      def index_algorithms
        {}
      end

      # CONNECTION MANAGEMENT ====================================

      # Checks whether the connection to the database is still active. This includes
      # checking whether the database is actually capable of responding, i.e. whether
      # the connection isn't stale.
      def active?
      end

      # Disconnects from the database if already connected, and establishes a
      # new connection with the database. Implementors should call super if they
      # override the default implementation.
      def reconnect!
        clear_cache!
        reset_transaction
      end

      # Disconnects from the database if already connected. Otherwise, this
      # method does nothing.
      def disconnect!
        clear_cache!
        reset_transaction
      end

      # Reset the state of this connection, directing the DBMS to clear
      # transactions and other connection-related server-side state. Usually a
      # database-dependent operation.
      #
      # The default implementation does nothing; the implementation should be
      # overridden by concrete adapters.
      def reset!
        # this should be overridden by concrete adapters
      end

      ###
      # Clear any caching the database adapter may be doing, for example
      # clearing the prepared statement cache. This is database specific.
      def clear_cache!
        # this should be overridden by concrete adapters
      end

      # Returns true if its required to reload the connection between requests for development mode.
      def requires_reloading?
        false
      end

      # Checks whether the connection to the database is still active (i.e. not stale).
      # This is done under the hood by calling <tt>active?</tt>. If the connection
      # is no longer active, then this method will reconnect to the database.
      def verify!(*ignored)
        reconnect! unless active?
      end

      # Provides access to the underlying database driver for this adapter. For
      # example, this method returns a Mysql object in case of MysqlAdapter,
      # and a PGconn object in case of PostgreSQLAdapter.
      #
      # This is useful for when you need to call a proprietary method such as
      # PostgreSQL's lo_* methods.
      def raw_connection
        @connection
      end

      def create_savepoint(name = nil)
      end

      def release_savepoint(name = nil)
      end

      def case_sensitive_modifier(node, table_attribute)
        node
      end

      def case_sensitive_comparison(table, attribute, column, value)
        table_attr = table[attribute]
        value = case_sensitive_modifier(value, table_attr) unless value.nil?
        table_attr.eq(value)
      end

      def case_insensitive_comparison(table, attribute, column, value)
        table[attribute].lower.eq(table.lower(value))
      end

      def current_savepoint_name
        current_transaction.savepoint_name
      end

      # Check the connection back in to the connection pool
      def close
        pool.checkin self
      end

      def type_map # :nodoc:
        @type_map ||= Type::TypeMap.new.tap do |mapping|
          initialize_type_map(mapping)
        end
      end

      def new_column(name, default, cast_type, sql_type = nil, null = true)
        Column.new(name, default, cast_type, sql_type, null)
      end

      def lookup_cast_type(sql_type) # :nodoc:
        type_map.lookup(sql_type)
      end

      def column_name_for_operation(operation, node) # :nodoc:
        visitor.accept(node, collector).value
      end

      class DatabaseLimits
      end

      protected

      def initialize_type_map(m) # :nodoc:
      end

      def extract_limit(sql_type)
      end
    end

    class MonetDBColumn < Column
    end

    module MonetDB
      module Quoting
      end

      module DatabaseStatements
      end

      module SchemaStatements
      end

      module DatabaseLimits
      end

      module QueryCache
      end

      module Savepoints
      end
    end
  end

end
