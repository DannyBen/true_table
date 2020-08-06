module TrueTable
  class Table < Array
    # Combines table with other and returns a new one
    def +(other)
      result = self.class.new
      each_row { |row, i| result << row.merge(other[i]) }
      result
    end

    # Returns a new table without the specified columns
    def -(cols)
      keep_keys = headers - cols
      result = self.class.new
      each_row { |row, i| result << row.slice(*keep_keys) }
      result
    end

    # Returns a row or a column
    def [](key)
      key.is_a?(Symbol) ? col(key) : super
    end

    # Adds or updates a row or a column
    def []=(key, value)
      key.is_a?(Symbol) ? add_col(key.to_sym, value) : super
    end

    # Returns a column as Array
    def col(key)
      map { |row| row[key] }
    end

    # Returns a hash of columns
    def cols
      result = {}
      each_col { |col, header| result[header] = col }
      result
    end

    # Returns a copy of self without rows that contain nil in any column
    def compact
      dup.compact!
    end

    # Removes rows with nil in any column
    def compact!
      delete_if { |row| row.values.include? nil }
    end

    # Delete a row or a column in place and returns the deleted row/column
    def delete_at(index)
      if index.is_a?(Symbol) || index.is_a?(String)
        result = self[index]
        return nil unless result
        each_row { |row, i| row.delete index }
        result
      else
        super
      end
    end
    alias delete_col delete_at
    alias delete_row delete_at

    # Returns a table with different rows
    def difference(*others)
      self.class.new super
    end

    # Extracts nested value. Accepts row, column or column, row
    def dig(*indexes)
      key = indexes.shift
      if key.is_a?(Symbol)
        col(key.to_sym).dig *indexes
      else
        row(key).dig *indexes
      end
    end

    # Iterates over columns
    def each_col
      headers.each { |header| yield col(header), header }
    end

    # Iterates over rows
    alias each_row each_with_index

    def fetch(key, *default)
      if key.is_a?(Symbol)
        if headers.include? key
          col(key.to_sym)
        elsif default.any?
          default.first
        elsif block_given?
          yield key
        else
          raise IndexError, "row :#{key} does not exist"
        end
      else
        super
      end
    end

    # Returns an array of column headers
    def headers
      first.keys
    end

    # Returns a new table with intersecting rows
    def intersection(*others)
      self.class.new super
    end

    # Returns a string with joined rows and columns
    def join(row_separator = $,, col_separator = nil, with_headers: false)
      if col_separator
        result = map { |row| row.values.join col_separator }.join(row_separator)
        with_headers ? headers.join(col_separator) + row_separator + result : result
      else
        super row_separator
      end
    end

    # Returns the last row or a new table with the last N rows
    def last(*args)
      args.empty? ? super : self.class.new(super)
    end

    # Returns a new table without rejected rows
    def reject
      self.class.new super
    end

    # Returns a reversed copy
    def reverse
      self.class.new super
    end

    # Returns a new table with the element at `count` as the first element
    def rotate(count = 1)
      self.class.new super
    end

    # Returns a row
    alias row []

    # Returns a new table with selected rows
    def select
      self.class.new super
    end
    alias filter select

    # Returns a new shuffled tables
    def shuffle(*args)
      self.class.new super
    end

    # Returns a new sorted table
    def sort
      self.class.new super
    end

    # Returns a new sorted table
    def sort_by
      self.class.new super
    end

    # Returns a CSV string
    def to_csv(row_separator = "\n", col_separator = ",")
      join(row_separator, col_separator, with_headers: true)
    end

    # Returns a hash representation of the table using the values of the
    # first column as hash keys
    def to_h
      map { |row| [row.values.first, row] }.to_h
    end

    # Returns only values, without any headers (array of arrays)
    def values
      map { |row| row.values }
    end

  protected

    def add_col(key, values)
      values.each_with_index do |value, i|
        self[i] ||= {}
        self[i][key] = value
      end
    end

  end
end
