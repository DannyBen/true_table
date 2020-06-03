module TableType
  class Table < Array
    # Returns a row or a column
    def [](key)
      key.is_a?(Symbol) ? col(key) : super
    end

    # Adds or updates a row or a column
    def []=(key, value)
      key.is_a?(Symbol) ? add_col(key, value) : super
    end

    # Returns a column as Array
    def col(key)
      map { |row| row[key] }
    end

    # Iterates over columns
    def each_col
      headers.each { |header| yield col(header), header }
    end

    # Iterates over rows
    alias each_row each_with_index

    # Returns an array of column headers
    def headers
      first.keys
    end

    # Returns a row
    alias row []

    def select
      self.class.new super
    end

    def sort_by
      self.class.new super
    end

  protected

    def add_col(key, values)
      values.each_with_index { |value, i| self[i][key] = value }
    end

  end
end