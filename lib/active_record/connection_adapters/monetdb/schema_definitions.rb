module ActiveRecord
  module ConnectionAdapters
    module MonetDB
      class IndexDefinition < ActiveRecord::ConnectionAdapters::IndexDefinition
      end

      class ColumnDefinition < ActiveRecord::ConnectionAdapters::ColumnDefinition
      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
      end
    end
  end
end
