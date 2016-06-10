require "MonetDB"

require "active_record/connection_adapters/abstract_adapter"
require "active_record/connection_adapters/column"
require "active_record/connection_adapters/statement_pool"

require "active_record/connection_adapters/monetdb/database_statements"
require "active_record/connection_adapters/monetdb/quoting"
require "active_record/connection_adapters/monetdb/schema_creation"
require "active_record/connection_adapters/monetdb/schema_definitions"
require "active_record/connection_adapters/monetdb/schema_statements"

module ActiveRecord
  module ConnectionHandling
    # Establishes a connection to the database that's used by all Active Record objects.
    def monetdb_connection(config)
      config = config.symbolize_keys

      client = MonetDB.new(config)
      config[:user] = config.delete[:username] || "monetdb"
      config[:passwd] = config.delete[:password] if config[:password]
      config[:db_name] = config.delete[:database] if config[:database]
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

      NATIVE_DATABASE_TYPES = {
        # According to the documentation, {PostgreSQL syntax}[https://www.monetdb.org/Documentation/SQLreference/TableIdentityColumn]
        # is also supported for primary keys
        primary_key: "serial primary key",
        # {Builtin SQL types}[https://www.monetdb.org/Documentation/Manuals/SQLreference/BuiltinTypes]
        string:      { name: "character varying" },
        text:        { name: "text" },
        integer:     { name: "integer" },
        bigint:      { name: "bigint" },
        float:       { name: "float" },
        decimal:     { name: "decimal" },
        boolean:     { name: "boolean" },
        binary:      { name: "blob" },
        # {Temporal types}[https://www.monetdb.org/Documentation/SQLreference/Temporal]
        datetime:    { name: "timestamp" },
        time:        { name: "time" },
        date:        { name: "date" },
        # {JSON datatype}[https://www.monetdb.org/Documentation/Manuals/SQLreference/Types/JSON]
        json:        { name: "json" },
        # {URL datatype}[https://www.monetdb.org/Documentation/Manuals/SQLreference/URLtype]
        url:         { name: "url" },
        # {UUID datatype}[https://www.monetdb.org/Documentation/Manuals/SQLreference/UUIDtype]
        uuid:        { name: "uuid" },
        # {Network Address Type}[https://www.monetdb.org/Documentation/Manuals/SQLreference/inet]
        inet:        { name: "inet" }
      }

      include MonetDB::DatabaseStatements
      include MonetDB::Quoting
      include MonetDB::SchemaStatements

      # Initializes a MonetDB adapter
      def initialize(connection, logger, connection_parameters, config)
        super(connection, logger)
      end

      def valid_type?(type)
        !native_database_types[type].nil?
      end

      def schema_creation
        MonetDB::SchemaCreation.new self
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
        true
      end

      def supports_partial_index?
        true
      end

      def supports_explain?
        false
      end

      def supports_transaction_isolation?
        true
      end

      def supports_extensions?
        false
      end

      def supports_indexes_in_create?
        true
      end

      def supports_foreign_keys?
        true
      end

      def supports_views?
        true
      end

      # This is meant to be implemented by the adapters that support extensions
      #def disable_extension(name)
      #end

      # This is meant to be implemented by the adapters that support extensions
      #def enable_extension(name)
      #end

      # A list of extensions, to be filled in by adapters that support them.
      #def extensions
      #  []
      #end

      # A list of index algorithms, to be filled by adapters that support them.
      def index_algorithms
        {}
      end

      # CONNECTION MANAGEMENT ====================================

      # Checks whether the connection to the database is still active. This includes
      # checking whether the database is actually capable of responding, i.e. whether
      # the connection isn't stale.
      def active?
        @connection.is_connected?
      end

      # Disconnects from the database if already connected, and establishes a
      # new connection with the database. Implementors should call super if they
      # override the default implementation.
      def reconnect!
        super
        @connection.reconnect
      end

      # Disconnects from the database if already connected. Otherwise, this
      # method does nothing.
      def disconnect!
        super
        @connection.close rescue nil
      end

      # Reset the state of this connection, directing the DBMS to clear
      # transactions and other connection-related server-side state. Usually a
      # database-dependent operation.
      #
      # The default implementation does nothing; the implementation should be
      # overridden by concrete adapters.
      def reset!
        clear_cache!
        reset_transaction
        @connection.query "ROLLBACK"
        reconnect!
      end

      ###
      # Clear any caching the database adapter may be doing, for example
      # clearing the prepared statement cache. This is database specific.
      def clear_cache!
        @statements.clear
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
        @connection.save
      end

      def release_savepoint(name = nil)
        @connection.release
      end

      def current_savepoint_name
        @connection.transactions
      end

      def new_column(name, default, cast_type, sql_type = nil, null = true)
        Column.new(name, default, cast_type, sql_type, null)
      end

      protected

      def initialize_type_map(m) # :nodoc:
        # Builtin SQL types
        m.register_type 'text', Type::Text.new
        register_class_with_limit m, 'varchar', Type::String
        m.alias_type 'char', 'varchar'
        m.alias_type 'name', 'varchar'
        m.register_type 'bool', Type::Boolean.new
        # Temporal types
        m.register_type 'date', Type::Date.new
        m.register_type 'time', Type::DateTime.new
        m.alias_type 'timestamptz', 'timestamp'
        m.register_type 'timestamp' do |_, _, sql_type|
          precision = extract_precision(sql_type)
          OID::DateTime.new(precision: precision)
        end
        # JSON datatype
        # m.register_type 'json', Type::Json.new
        # URL datatype
        # m.register_type 'url', Type::SpecializedString.new(:url)
        # UUID datatype
        # m.register_type 'uuid', Type::Uuid.new
        # Network Address Type
        # m.register_type 'inet', Type::Inet.new
        # Additional numeric types
        m.register_type 'numeric' do |_, fmod, sql_type|
          precision = extract_precision(sql_type)
          scale = extract_scale(sql_type)

          # The type for the numeric depends on the width of the field,
          # so we'll do something special here.
          #
          # When dealing with decimal columns:
          #
          # places after decimal  = fmod - 4 & 0xffff
          # places before decimal = (fmod - 4) >> 16 & 0xffff
          if fmod && (fmod - 4 & 0xffff).zero?
            Type::DecimalWithoutScale.new(precision: precision)
          else
            Type::Decimal.new(precision: precision, scale: scale)
          end
        end
      end

      def extract_limit(sql_type) # :nodoc:
        case sql_type
        when /^hugeint/i
          16
        when /^bigint/i
          8
        when /^smallint/i
          2
        when /^tinyint/i
          1
        else
          super
        end
      end

      def native_database_types
        NATIVE_DATABASE_TYPES
      end

      def extract_table_ref_from_insert_sql(sql) # :nodoc:
        sql[/into\s("[A-Za-z0-9_."\[\]\s]+"|[A-Za-z0-9_."\[\]]+)\s*/im]
        $1.strip if $1
      end
    end
  end
end
