module LimeExt
    
    ##
    # Class: LimeData
    #
    # The LimeData class is used to generate datasets from LimeSurvey datasets
    class PolyTableModel
        SQL_SUB_REGEX = /[^A-Za-z0-9 @,._]+/
        
        attr_accessor :sid, :query 
        
        ##
        # Build query
        def query
            query="SELECT * FROM #{self.class.table_name(sid)}"
            query += " WHERE " if filters.size > 0
            query += filters.map{|fopts| " \"#{fopts[:col]}\" = '#{fopts[:val]}' "}.join(' AND ')
            return query
        end
        
        def filter_names
            @filter_names ||= [] 
        end
               
        ##
        # run sql query 
        def self.run_sql a_query
            raise LimeQueryError, 'Query Missing' if a_query.to_s.empty? 
            # execute the query
            data = Array ActiveRecord::Base.connection.execute(a_query)
            return [] if data.empty?
            return data
        end 
        
        ##
        # return dataset/return copy if already generated
        def dataset
            @dataset = nil if dataset_stale? 
            @dataset ||= self.class.run_sql(query)
            return @dataset
        end
        
        ##
        # Does this table exist?
        def table_exists?
            ActiveRecord::Base.connection.table_exists? self.class.table_name(sid) 
        end
        
        ##
        # Return array of column names for this survey
        def column_names
            return @column_names if defined? @column_names
            query = "
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema='#{LimeExt.schema}' AND table_name='#{self.class.table_name(sid)}'"
            result = Array ActiveRecord::Base.connection.execute(query)
            @column_names = result.map{|col|col["column_name"]}
        end
        
        def empty?
            dataset.empty?
        end
        
        def responses_for fieldname
            fieldname = fieldname.to_s
            return [] unless column_names.include? fieldname
            dataset.map{|row|row[fieldname]}
        end
       
        def pluck *fieldnames
            fieldnames = fieldnames.map{|fname|fname.to_s}
            fieldnames.each do |fname|
                return unless column_names.include? fname
            end
            dataset.map{|row|row.values_at(*fieldnames)}
        end
        
        ##
        # Is this dataset filtered?
        def filtered?
            filters.size > 0
        end
        
        ##
        # Add a filter to the dataset generator
        def add_filter col, val, opts={}
            col = self.class.sql_sub(col)
            val = self.class.sql_sub(val)
            if col.to_s.empty? || val.to_s.empty?
                raise LimeExt::Errors::LimeDataFiltersError,  'Error adding filter'
            end
            @dataset_stale = true
            filters.push(opts.merge({:col=>col, :val=>val})).uniq!
            filter_names.push(opts[:name]||val)
            return self
        end
        
        ##
        # An array of filters to apply to the dataset
        def filters
            @filters ||= []
        end
        
        ##
        # Is the dataset stale?
        def dataset_stale?
            return @dataset_stale ||= false
        end
        
        ##
        # SQL secure substitution
        def self.sql_sub val
            xval = val.to_s.gsub(SQL_SUB_REGEX,'')
            warn("Caught illegal characters in: #{val}") if xval != val.to_s
            return xval 
        end
        
    end
end

