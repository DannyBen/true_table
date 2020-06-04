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

  describe '#+' do
    before { @result = subject + other }

    it "combines two tables into a new one" do
      expect(@result.to_yaml).to match_approval "plus"
    end

    it "does not alter the original" do
      expect(subject.to_yaml).to match_approval "original"
    end
  end

  describe '#-' do
    before { @result = subject - [:population] }

    it "deletes one or more columns" do
      expect(@result.to_yaml).to match_approval "minus"
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

  describe '#headers' do
    it "returns the hash keys from the first row" do
      expect(subject.headers).to eq [:year, :population]
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

  describe '#row' do
    it "returns a row" do
      expect(subject.row(1)[:year]).to eq 2021
    end
  end
end
