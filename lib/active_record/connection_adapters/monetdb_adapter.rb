require "active_record/connection_adapters/abstract_adapter"
require "MonetDB"

module ActiveRecord
  module ConnectionHandling
  end

  module ConnectionAdapters
    class MonetDBAdapter < AbstractAdapter
      # Initializes and connects a MonetDB adapter
      def initialize(connection, logger, connection_parameters, config)
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
