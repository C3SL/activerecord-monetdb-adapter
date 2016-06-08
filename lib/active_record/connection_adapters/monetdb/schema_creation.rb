module ActiveRecord
  module ConnectionAdapters
    module MonetDB
      class SchemaCreation < AbstractAdapter::SchemaCreation
        def accept(o)
        end

        def visit_AddColumn(o)
        end

        private

        def visit_AlterTable(o)
        end

        def visit_ColumnDefinition(o)
          sql = super
          if o.primary_key? && o.type != :primary_key
            sql << " PRIMARY KEY "
            add_column_options!(sql, column_options(o))
          end
          sql
        end

        def visit_TableDefinition(o)
        end

        def visit_AddForeignKey(o)
        end

        def visit_DropForeignKey(o)
        end

        def column_options(o)
        end

        def quote_column_name(name)
        end

        def quote_table_name(name)
        end

        def type_to_sql(type, limit, precision, scale)
        end

        def add_column_options!(sql, options)
          if options[:array] || options[:column].try(:array)
            sql << '[]'
          end

          column = options.fetch(:column) { return super }
          if column.type == :uuid && options[:default] =~ /\(\)/
            sql << " DEFAULT #{options[:default]}"
          else
            super
          end
        end

        def quote_value(value, column)
        end

        def options_include_default?(options)
        end

        def action_sql(action, dependency)
        end

        def type_for_column(column)
          if column.array
            @conn.lookup_cast_type("#{column.sql_type}[]")
          else
            super
          end
        end
      end
    end
  end
end

