require 'spec_helper'

describe Table do
  subject { described_class.new data }
  let(:data) {[
    { year: 2020, population: 2000000 },
    { year: 2021, population: 20000 },
    { year: 2022, population: 200 },
    { year: 2023, population: 2 },
  ]}

  let(:other) { described_class.new other_data }
  let(:other_data) {[
    { infected: 0 },
    { infected: 1980000 },
    { infected: 1999800 },
    { infected: 1999998 },
  ]}

  it "is a subclass of Array" do
    expect(subject).to be_an Array
  end

  describe 'class methods' do
    subject { described_class }

    describe '::from_csv' do
      pending
    end
  end

  describe '#+' do
    it "combines two tables into a new one" do
      result = subject + other
      expect(result.to_yaml).to match_approval "plus"
    end

    it "does not alter the original" do
      expect(subject.to_yaml).to match_approval "original"
    end
  end

  describe '#-' do

    it "returns a new table without subtracted columns" do
      result = subject - [:population]
      expect(result.to_yaml).to match_approval "minus"
    end

    it "does not alter the original" do
      expect(subject.to_yaml).to match_approval "original"
    end
  end

  describe '#[]' do
    context "with an integer key" do
      it "returns a row" do
        expect(subject[2][:population]).to eq 200        
      end
    end
    
    context "with a symbol key" do
      it "returns a column" do
        expect(subject[:population][3]).to eq 2
      end
    end
  end

  describe '#[]=' do
    context "with an integer key" do
      it "adds or updates the row" do
        subject[4] = { year: 2024, population: 3 }
        expect(subject[:population]).to eq [2000000, 20000, 200, 2, 3]
      end
    end
    
    context "with a symbol key" do
      it "adds or updates the column" do
        subject[:infected] = [0, 1980000, 1999800, 1999998]
        expect(subject[1]).to eq({ population: 20000, year: 2021, infected: 1980000 })
      end
    end
  end

  describe '#clone' do
    it "returns a deep copy without altering the original" do
      copy = subject.clone
      copy[:cured] = ["10%", "5%", "3%", "1%"]
      expect(subject.headers).to eq [:year, :population]
      expect(copy.headers).to eq [:year, :population, :cured]
    end
  end

  describe '#col' do
    it "returns a column" do
      expect(subject.col(:year)[1]).to eq 2021
    end
  end

  describe '#cols' do
    it "returns a hash of columns" do
      expect(subject.cols.to_yaml).to match_approval "cols"
    end
  end

  describe '#combination' do
    it "yields the row combinations" do
      expect(subject.combination(2).to_a.count).to eq 6
    end
  end

  describe '#compact' do
    before { data[1][:population] = nil }

    it "returns a copy without rows that contain nil columns" do
      expect(subject.compact.count).to eq data.compact.count - 1
    end
  end

  describe '#compact!' do
    before { subject[1][:population] = nil }

    it "removes rows with nil columns" do
      subject.compact!
      expect(subject.count).to eq 3
    end
  end

  describe '#concat' do
    it "appends the other table to self" do
      subject.concat other
      expect(subject.count).to eq 8
    end
  end

  describe '#cycle' do
    it "calls the block N times for each row" do
      count = 0
      subject.cycle(2) { |_row| count += 1 }
      expect(count).to eq subject.count * 2
    end
  end

  describe '#delete' do
    it "deletes rows for which the block returns true" do
      subject.delete({ year: 2021, population: 20000 })
      expect(subject.count).to eq 3
    end
  end

  describe '#delete_at' do
    context "with an integer argument" do
      it "deletes a row in place and returns the deleted row" do
        expect(subject.delete_at 1).to eq({ population: 20000, year: 2021 })
        expect(subject.count).to eq 3
      end
    end

    context "with a symbol argument" do
      it "deletes a column in place and returns the deleted column" do
        expect(subject.delete_at :year).to eq [2020, 2021, 2022, 2023]
        expect(subject.headers).to eq [:population]
      end
    end
  end

  describe '#delete_if' do
    it "deletes rows for which the block returns true" do
      subject.delete_if { |row| row[:year] == 2021 }
      expect(subject.count).to eq 3
    end
  end

  describe '#difference' do
    let(:other) {[
      { year: 2020, population: 2000000 },
      { year: 2023, population: 2 },
    ]}

    it "returns a new Table consisting only difference rows" do
      result = subject.difference(other)
      expect(result.count).to eq 2
      expect(result[:year]).to eq [2021, 2022]
    end    
  end

  describe '#dig' do
    context "with row, column" do
      it "extracts the nested value" do
        expect(subject.dig 1, :year).to eq 2021
      end
    end

    context "with column, row" do
      it "extracts the nested value" do
        expect(subject.dig :year, 1).to eq 2021
      end
    end
  end

  describe '#drop' do
    it "drops the first N rows" do
      expect(subject.drop(2).count).to eq subject.count - 2
    end

    it "returns a Table object" do
      expect(subject.drop(2)).to be_a Table
    end
  end

  describe '#drop_while' do
    it "drops rows until the block returns false" do
      result = subject.drop_while { |row| row[:year] < 2022 }
      expect(result[0][:year]).to eq 2022
    end

    it "returns a Table" do
      result = subject.drop_while { |row| row[:year] < 2022 }
      expect(result).to be_a Table
    end
  end

  describe '#each_col' do
    it "yields the columns and their names" do
      subject.each_col do |col, header|
        expect(col).to eq subject[header]
      end
    end
  end

  describe '#each_row' do
    it "yields the rows and their indexes" do
      subject.each_row do |row, i|
        expect(row).to eq subject[i]
      end
    end
  end

  describe '#eql?' do
    it "returns true for identical objects" do
      expect(subject.eql? subject.dup).to be true
    end
  end

  describe '#fetch' do
    context "with an integer argument" do
      it "returns a row" do
        expect(subject.fetch 1).to eq({ year: 2021, population: 20000 })
      end

      context "when it is out of bounds" do
        it "raises IndexError" do
          expect { subject.fetch 99 }.to raise_error(IndexError)
        end
      end

      context "when it is out of bounds but a default is given" do
        it "returns the default value" do
          expect(subject.fetch 99, "ok").to eq "ok"
        end
      end
    end

    context "with a symbol argument" do
      it "returns a column" do
        expect(subject.fetch :year).to eq([2020, 2021, 2022, 2023])
      end

      context "when it is out of bounds" do
        it "raises IndexError" do
          expect { subject.fetch :no_such_column }.to raise_error(IndexError)
        end
      end

      context "when it is out of bounds but a default is given" do
        it "returns the default value" do
          expect(subject.fetch :no_such_column, "ok").to eq "ok"
        end
      end

      context "when it is out of bounds but a block is given" do
        it "returns the default value" do
          result = subject.fetch :no_such_column do |index|
            "received :#{index}"
          end
          expect(result).to eq "received :no_such_column"
        end
      end
    end
  end

  describe '#fill' do
    it "replaces the rows" do
      subject.fill { |index| { pos: index } }
      expect(subject[:pos]).to eq [0, 1, 2, 3]
    end
  end

  describe '#filter' do
    it "returns a new table with matching rows" do
      result = subject.filter { |row| row[:population] < 20000 }
      
      expect(result).to be_a Table
      expect(result.count).to eq 2
      expect(subject.count).to eq 4
    end
  end

  describe '#filter!' do
    it "keeps only selected rows" do
      subject.filter! { |row| row[:population] < 20000 }

      expect(subject[:population]).to eq [200, 2]
    end
  end

  describe '#find_index' do
    it "returns the index of the first matching row" do
      result = subject.find_index { |row| row[:year] == 2021 }
      expect(result).to eq 1
    end
  end

  # describe '#flatten' - not relevant
  # describe '#flatten!' - not relevant

  describe '#headers' do
    it "returns the hash keys from the first row" do
      expect(subject.headers).to eq [:year, :population]
    end
  end

  describe '#include?' do
    it "returns true of the row exists" do
      expect(subject.include? year: 2020, population: 2000000).to be true
    end
  end

  describe '#index' do
    it "returns the index of the first matching row" do
      result = subject.index { |row| row[:year] == 2021 }
      expect(result).to eq 1
    end
  end

  describe '#insert' do
    it "inserts the given rows before the given index" do
      subject.insert(2, other[0], other[1])
      expect(subject[2]).to eq other[0]
      expect(subject[3]).to eq other[1]
      expect(subject.count).to eq 6
    end
  end

  describe '#intersection' do
    let(:other) {[
      { year: 2021, population: 20000 },
      { year: 2023, population: 2 },
    ]}

    it "returns a new table with intersecting rows" do
      result = subject.intersection other
      expect(result[:year]).to eq [2021, 2023]      
    end
  end

  describe '#join' do
    context "with no arguments" do
      it "returns a joined string" do
        expect(subject.join).to match_approval 'join-no-args'
      end
    end

    context "with row separator argument" do
      it "returns a joined string using the separator as glue" do
        expect(subject.join ' | ').to match_approval 'join-rows'
      end
    end

    context "with row and col separator arguments" do
      it "returns a joined string using the separators as glue" do
        expect(subject.join "\n", ",").to match_approval 'join-rows-cols'
      end
    end
  end

  describe '#keep_if' do
    it "keeps only rows for which the block returns true" do
      subject.keep_if { |row| row[:year] < 2022 }
      expect(subject[:year]).to eq [2020, 2021]
    end    
  end

  describe '#length' do
    it "returns the number of rows" do
      expect(subject.length).to eq 4      
    end
  end

  describe '#max' do
    it "returns the row with the maximum block value" do
      result = subject.max do |a, b|
        a[:population] <=> b[:population]
      end
      expect(result[:year]).to eq 2020
    end
  end

  describe '#min' do
    it "returns the row with the minimum block value" do
      result = subject.min do |a, b|
        a[:population] <=> b[:population]
      end
      expect(result[:year]).to eq 2023
    end
  end

  describe '#minmax' do
    it "returns a two element array with min and max rows" do
      result = subject.minmax do |a, b|
        a[:population] <=> b[:population]
      end
      expect(result[0][:year]).to eq 2023
      expect(result[1][:year]).to eq 2020
    end
  end

  describe '#permutation' do
    it "yields the row permutations" do
      expect(subject.permutation.count).to eq 24
    end
  end

  describe '#pop' do
    it "removes the last element and returns it" do
      expect(subject.pop[:year]).to eq 2023
      expect(subject.count).to eq 3
    end
  end

  describe '#prepend' do
    it "inserts a row at the beginning" do
      subject.prepend({ year: 2019, population: 3000000 })
      expect(subject.count).to eq 5
      expect(subject[0][:year]).to eq 2019
    end
  end

  describe '#push' do
    it "appends a row to the table" do
      subject.push year: 2024, population: 0
      expect(subject.count).to eq 5
    end
  end

  describe '#reject' do
    it "returns a new table without matching rows" do
      result = subject.reject { |row| row[:population] < 20000 }
      
      expect(result).to be_a Table
      expect(result.count).to eq 2
      expect(subject.count).to eq 4
    end
  end

  describe '#reject!' do
    it "keeps only non-rejected rows" do
      subject.reject! { |row| row[:population] < 20000 }

      expect(subject[:population]).to eq [2000000, 20000]
    end
  end

  describe '#replace' do
    it "replaces the table with a new table" do
      subject.replace other
      expect(subject[:infected][1]).to eq 1980000
      expect(subject).to be_a Table
    end
  end

  describe '#reverse' do
    it "returns a new reversed table" do
      result = subject.reverse
      
      expect(result).to be_a Table
      expect(result.first[:year]).to eq subject.last[:year]
    end
  end

  describe '#reverse!' do
    it "reverses the table in place" do
      original_year = subject.last[:year]

      subject.reverse!

      expect(subject.first[:year]).to eq original_year
    end
  end

  describe '#rindex' do
    it "returns the index of the last matching row" do
      result = subject.rindex { |row| row[:year] <= 2021 }
      expect(result).to eq 1
    end
  end

  describe '#rotate' do
    it "offsets the rows to the top" do
      expect(subject.rotate(2)[0][:year]).to eq 2022
      expect(subject.rotate(2)).to be_a Table
    end
  end

  describe '#rotate!' do
    it "rotates the table in place" do
      subject.rotate! 2
      expect(subject[0][:year]).to eq 2022
      expect(subject).to be_a Table
    end
  end

  describe '#row' do
    it "returns a row" do
      expect(subject.row(1)[:year]).to eq 2021
    end
  end

  describe '#sample' do
    it "returns one a random row" do
      expect(subject.sample).to be_a Hash
    end

    context "with an argument" do
      it "returns an array with multiple random rows" do
        expect(subject.sample(2).count).to eq 2
      end
    end
  end

  describe '#select' do
    it "returns a new table with matching rows" do
      result = subject.select { |row| row[:population] < 20000 }
      
      expect(result).to be_a Table
      expect(result.count).to eq 2
      expect(subject.count).to eq 4
    end
  end

  describe '#select!' do
    it "keeps only selected rows" do
      subject.select! { |row| row[:population] < 20000 }

      expect(subject[:population]).to eq [200, 2]
    end
  end

  describe '#shift' do
    it "removes the first N rows" do
      expect(subject.shift[:year]).to eq 2020
      expect(subject.count).to eq 3
      expect(subject).to be_a Table
    end
  end

  describe '#shuffle' do
    it "returns a new table with shuffled rows" do
      expect(subject.shuffle).to be_a Table
    end
  end

  describe '#shuffle!' do
    it "shuffles the table in place" do
      subject.shuffle!
      expect(subject).to be_a Table
    end
  end

  describe '#slice' do
    context "with one argument" do
      it "returns the row at index" do
        expect(subject.slice(1)[:year]).to eq 2021
      end
    end

    context "with two arguments" do
      it "returns a new table slice" do
        result = subject.slice(1, 2)

        expect(result).to be_a Table
        expect(result.count).to eq 2
        expect(result.first[:year]).to eq 2021
      end
    end
  end

  describe '#slice!' do
    it "deletes and returns one or more" do
      result = subject.slice!(0, 3)

      expect(result).to be_a Table
      expect(result.count).to eq 3
      expect(subject.count).to eq 1
    end
  end

  describe '#sort' do
    it "returns a new sorted array" do
      result = subject.sort { |a, b| a[:population] <=> b[:population] }

      expect(result).to be_a Table
      expect(result[0][:population]).to eq 2
      expect(result[3][:population]).to eq 2000000
      expect(subject[0][:population]).to eq 2000000
    end
  end

  describe '#sort!' do
    it "sorts the table in place" do
      subject.sort! { |a, b| a[:population] <=> b[:population] }

      expect(subject[0][:population]).to eq 2
      expect(subject[3][:population]).to eq 2000000
    end
  end

  describe '#sort_by' do
    it "returns a new sorted array" do
      result = subject.sort_by { |row| row[:population] }

      expect(result).to be_a Table
      expect(result[0][:population]).to eq 2
      expect(result[3][:population]).to eq 2000000
      expect(subject[0][:population]).to eq 2000000
    end
  end

  describe '#sort_by!' do
    it "sorts the table in place" do
      subject.sort_by! { |row| row[:population] }

      expect(subject[0][:population]).to eq 2
      expect(subject[3][:population]).to eq 2000000
    end
  end

  describe '#take' do
    it "returns a new table with the first N rows" do
      result = subject.take 2
      
      expect(result).to be_a Table
      expect(result.count).to eq 2
      expect(subject.count).to eq 4
    end
  end

  describe '#take_while' do
    it "takes rows until the block returns false" do
      result = subject.take_while { |row| row[:year] < 2022 }
      expect(result.count).to eq 2
      expect(result[1][:year]).to eq 2021
    end

    it "returns a Table" do
      result = subject.take_while { |row| row[:year] < 2022 }
      expect(result).to be_a Table
    end
  end

  describe '#to_a' do
    it "returns an Array" do
      expect(subject.to_a).to be_an Array
      expect(subject.to_a).not_to be_a Table
    end
  end

  describe '#to_ary' do
    it "returns self" do
      expect(subject.to_ary).to be_a Table
    end
  end

  describe '#to_csv' do
    it "returns a CSV string" do
      expect(subject.to_csv).to match_approval 'csv'
    end
  end

  describe '#to_h' do
    it "returns a hash using the values of the first column as keys" do
      result = subject.to_h
      
      expect(result).to be_a Hash
      expect(result[2022][:population]).to eq 200
    end
  end

  describe '#union' do
    pending
  end

  describe '#values' do
    it "returns an array of arrays" do
      result = subject.values
      
      expect(result).to be_an Array
      expect(result.first).to eq [2020, 2000000]
    end
  end

  describe '#values_at' do
    pending
  end

  describe '#zip' do
    pending
  end

  describe '#|' do
    pending
  end
end
