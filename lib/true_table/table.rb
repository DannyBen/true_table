module TrueTable
  class Table < Array
    def +(other)
      result = self.class.new
      each_row { |row, i| result << row.merge(other[i]) }
      result
    end

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
      key.is_a?(Symbol) ? add_col(key, value) : super
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

    # Returns a new table without rejected rows
    def reject
      self.class.new super
    end

    # Keeps only rows that are not rejected
    def reject!
      self.class.new super
    end

    # Returns a reversed copy
    def reverse
      self.class.new super
    end

    # Reverse in place
    def reverse!
      self.class.new super
    end


    # Returns a row
    alias row []

    # Returns a new table with selected rows
    def select
      self.class.new super
    end

    # Keeps only selected rows
    def select!
      self.class.new super
    end

    # Returns a new sorted table
    def sort_by
      self.class.new super
    end

    # Sorts the table in place
    def sort_by!
      self.class.new super
    end

  protected

    def add_col(key, values)
      values.each_with_index { |value, i| self[i][key] = value }
    end

  end
end


# To implement:

#collect
#collect!
#reverse_each
#transpose
#sort
#sort!

# ::from_csv
# ::from_tsv
# ::to_csv
# ::to_tsv

#combination
#compact
#compact!
#concat
#cycle
#deconstruct
#delete
#delete_at
#delete_if
#difference
#dig
#drop
#drop_while
#eql?
#fetch
#fill
#filter
#filter!
#find_index
#first
#flatten
#flatten!
#hash
#include?
#index
#initialize_copy
#insert
#inspect
#intersection
#join
#keep_if
#last
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
