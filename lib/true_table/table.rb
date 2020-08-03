module TrueTable
  class Table < Array
    # Combines table with other and returns a new one
    def +(other)
      result = self.class.new
      each_row { |row, i| result << row.merge(other[i]) }
      result
    end

    # Returns a new table without specified columns
    def -(cols)
      keep_keys = headers - cols
      result = self.class.new
      each_row { |row, i| result << row.slice(*keep_keys) }
      result
    end

    # Returns a row or a column
    def [](key)
      key.is_a?(Symbol) || key.is_a?(String) ? col(key.to_sym) : super
    end

    # Adds or updates a row or a column
    def []=(key, value)
      key.is_a?(Symbol) || key.is_a?(String) ? add_col(key.to_sym, value) : super
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

    # Extracts nested value. Accepts row, column or column, row
    def dig(*indexes)
      key = indexes.shift
      if key.is_a?(Symbol) || key.is_a?(String)
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

    # Returns an array of column headers
    def headers
      first.keys
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

    # Returns a row
    alias row []

    # Returns a new table with selected rows
    def select
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


# To implement:

# ::from_csv
# ::from_tsv
# ::to_csv
# ::to_tsv

#join
#keep_if
#length
#max
#min
#minmax
#none?
#old_to_s
#one?
#pack
#permutation
#pop
#prepend
#product
#push
#rassoc
#repeated_combination
#repeated_permutation
#replace
#rindex
#rotate
#rotate!
#sample
#shift
#shuffle
#shuffle!
#slice
#slice!
#take
#take_while
#to_a
#to_ary
#to_h
#union
#unshift
#values_at
#zip
#|
