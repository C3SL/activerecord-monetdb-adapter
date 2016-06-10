module ActiveRecord
  module ConnectionAdapters
    module MonetDB
      module DatabaseStatements

        # Returns a single value from a record
        #def select_value(arel, name = nil, binds = [])
        #end

        # Returns an array of the values of the first column in a select:
        #   select_values("SELECT id FROM companies LIMIT 3") => [1,2,3]
        #def select_values(arel, name = nil)
        #end

        # Returns an array of arrays containing the field values.
        # Order is the same as that returned by +columns+.
        #def select_rows(sql, name = nil, binds = [])
        #end

        # Executes the SQL statement in the context of this connection.
        def execute(sql, name = nil)
          log(sql, name) do
            @connection.query(sql)
          end
        end

        # Executes +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        def exec_query(sql, name = 'SQL', binds = [])
          result = @connection.query(sql)
          result_set = result.fetchall
          columns = result.name_fields
          types = result.type_fields
          ActiveRecord::Result.new(result_set, columns, types)
        end

        # Executes insert +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        #def exec_insert(sql, name, binds, pk = nil, sequence_name = nil)
        #end

        # Executes delete +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        #def exec_delete(sql, name, binds)
        #  exec_query(sql, name, binds)
        #end

        # Executes the truncate statement.
        def truncate(table_name, name = nil)
          exec_query "DELETE FROM #{quote_table_name(table_name)}", name, []
        end

        # Executes update +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        #def exec_update(sql, name, binds)
        #  exec_query(sql, name, binds)
        #end

        protected

        def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
          unless pk
            table_ref = extract_table_ref_from_insert_sql(sql)
            pk = primary_key(table_ref) if table_ref
          end

          if pk
            super
            last_insert_id_value(sequence_name || default_sequence_name(table_ref, pk))
          else
            super
          end
        end

        def update_sql(sql, name = nil)
        end

        def delete_sql(sql, name = nil)
        end

        def sql_for_insert(sql, pk, id_value, sequence_name, binds)
        end

      end
    end
  end
end
