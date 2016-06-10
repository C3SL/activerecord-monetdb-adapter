module ActiveRecord
  module ConnectionAdapters
    module MonetDB
      module DatabaseStatements

        # Returns a single value from a record
        def select_value(arel, name = nil, binds = [])
        end

        # Returns an array of the values of the first column in a select:
        #   select_values("SELECT id FROM companies LIMIT 3") => [1,2,3]
        def select_values(arel, name = nil)
        end

        # Returns an array of arrays containing the field values.
        # Order is the same as that returned by +columns+.
        def select_rows(sql, name = nil, binds = [])
        end

        # Executes the SQL statement in the context of this connection.
        def execute(sql, name = nil)
            log(sql, name) do
                @connection.async_exec(sql)
            end
        end

        # Executes +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        def exec_query(sql, name = 'SQL', binds = []) # 
            execute_and_clear(sql, name, binds) do |result|
                types = {}
                fields = result.fields
                fields.each_with_index do |fname, i|
                    ftype = result.ftype i
                    fmod  = result.fmod i
                    types[fname] = get_oid_type(ftype, fmod, fname)
                end
                ActiveRecord::Result.new(fields, result.values, types)
            end
        end

        # Executes insert +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        def exec_insert(sql, name, binds, pk = nil, sequence_name = nil)
        end

        # Executes delete +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        def exec_delete(sql, name, binds)
          exec_query(sql, name, binds)
        end

        # Executes the truncate statement.
        def truncate(table_name, name = nil)
          raise NotImplementedError
        end

        # Executes update +sql+ statement in the context of this connection using
        # +binds+ as the bind substitutes. +name+ is logged along with
        # the executed +sql+ statement.
        def exec_update(sql, name, binds)
          exec_query(sql, name, binds)
        end

        protected

        def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
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
