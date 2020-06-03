require 'spec_helper'

describe Table do
  subject { described_class.new data }
  let(:data) {[
    { year: 2020, population: 2000000 },
    { year: 2021, population: 20000 },
    { year: 2022, population: 200 },
    { year: 2023, population: 2 },
  ]}

  it "is a subclass of Array" do
    expect(subject).to be_an Array
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

  describe '#row' do
    it "returns a row" do
      expect(subject.row(1)[:year]).to eq 2021
    end
  end

  describe '#headers' do
    it "returns the hash keys from the first row" do
      expect(subject.headers).to eq [:year, :population]
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
end
