require 'csv'

class TrueTable < Array
  class << self
    # Loads a CSV string
    #
    # @example
    #   csv = "id,name\n1,Harry\n2,Lloyd"
    #   table = TrueTable.load_csv csv, converters: [:date, :numeric]
    #
    # @param [String] csv_string CSV string.
    # @param [Hash] options options to forward to the CSV class.
    #
    # @return [TrueTable] the new table object
    def from_csv(csv_string, options = {})
      default_options = { headers: true, converters: :numeric, header_converters: :symbol }
      csv = CSV.new csv_string, **default_options.merge(options)
      new.tap do |table|
        csv.each { |row| table << row.to_h }
      end
    end

    # Loads a CSV file
    #
    # @example
    #   table = TrueTable.from_csv "sample.csv", converters: [:date, :numeric]
    #
    # @param [String] path the path to the CSV file.
    # @param [Hash] options options to forward to the CSV class.
    #
    # @return [TrueTable] the new table object
    def load_csv(path, options = {})
      from_csv File.read(path), options
    end
  end

  # Combines table with other and returns a new one
  def +(other)
    result = self.class.new
    each_row { |row, i| result << row.merge(other[i]) }
    result
  end

  # Returns a new table without the specified columns
  def -(other)
    keep_keys = headers - other
    result = self.class.new
    each_row { |row, _i| result << row.slice(*keep_keys) }
    result
  end

  # Returns a row or a column
  def [](key)
    case key
    when Symbol then col(key)
    when Hash   then row(key)
    else super
    end
  end

  # Adds or updates a row or a column
  def []=(key, value)
    case key
    when Symbol then add_col(key.to_sym, value)
    when Hash   then add_row(key, value)
    else super
    end
  end

  # Returns a deep copy of self
  def clone
    self.class.new map(&:clone)
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
    delete_if { |row| row.has_value?(nil) }
  end

  # Delete a row or a column in place and returns the deleted row/column
  def delete_at(index)
    if index.is_a?(Symbol) || index.is_a?(String)
      result = self[index]
      return nil unless result

      each_row { |row, _i| row.delete index }
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
      col(key.to_sym).dig(*indexes)
    else
      row(key).dig(*indexes)
    end
  end

  # Returns a new table without the first N rows
  def drop(*args)
    self.class.new super
  end

  # Returns a new table with rows until the block returns false
  def drop_while(*args)
    self.class.new super
  end

  # Iterates over columns
  def each_col
    headers.each { |header| yield col(header), header }
  end

  # Iterates over rows
  alias each_row each_with_index

  # Returns a row or a column
  def fetch(key, *default)
    case key
    when Symbol
      if headers.include?(key) then col(key.to_sym)
      elsif default.any? then default.first
      elsif block_given? then yield key
      else raise IndexError, "col :#{key} does not exist"
      end

    when Hash
      result = row(key)
      if result then result
      elsif default.any? then default.first
      elsif block_given? then yield key
      else raise IndexError, "row #{key} does not exist"
      end

    else
      super
    
    end
  end

  # Returns an array of column headers
  def headers
    first.keys
  end

  # Returns a short inspection string
  def inspect
    "<#{self.class}:#{object_id} size=#{size} headers=#{headers}>"
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
  def row(key)
    key.is_a?(Hash) ? find { |x| x[key.first.first] == key.first.last } : self[key]
  end

  # Returns all rows
  alias rows to_a

  # Saves the table as a CSV file
  def save_csv(path)
    File.write path, to_csv
  end

  # Saves the table as a TSV file
  def save_tsv(path)
    File.write path, to_tsv
  end

  # Returns a new table with selected rows
  def select
    self.class.new super
  end
  alias filter select

  # Returns a new shuffled tables
  def shuffle(*args)
    self.class.new super
  end

  # Returns a new table slice
  def slice(*args)
    if (args.count == 1) && args.first.is_a?(Integer)
      super
    else
      self.class.new super
    end
  end

  # Deletes and returns one more rows
  def slice!(*args)
    if (args.count == 1) && args.first.is_a?(Integer)
      super
    else
      self.class.new super
    end
  end

  # Returns a new sorted table
  def sort
    self.class.new super
  end

  # Returns a new sorted table
  def sort_by
    self.class.new super
  end

  # Returns a new table with the first N rows
  def take(*args)
    self.class.new super
  end

  # Returns a new table with rows until the block returns false
  def take_while(*args)
    self.class.new super
  end

  # Returns a CSV string
  def to_csv(row_separator = "\n", col_separator = ',')
    join(row_separator, col_separator, with_headers: true)
  end

  # Returns a TSV string
  def to_tsv(row_separator = "\n", col_separator = "\t")
    join(row_separator, col_separator, with_headers: true)
  end

  # Returns a hash representation of the table using the values of the
  # first column as hash keys. If a block is given, the results of the block
  # on each element of the array will be used as key => value pair.
  def to_h
    if block_given?
      super
    else
      super { |row| [row.values.first, row] }
    end
  end

  # Returns only values, without any headers (array of arrays)
  def values
    map(&:values)
  end

protected

  def add_col(key, values)
    values.each_with_index do |value, i|
      self[i] ||= {}
      self[i][key] = value
    end
  end

  def add_row(key, values)
    row(key).merge! values
  end
end
