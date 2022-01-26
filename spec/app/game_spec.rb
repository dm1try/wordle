require 'spec_helper'
require_relative '../../app/game'

describe Game do
  subject { described_class.new("plain") }

  it 'allows to win' do
    expect(subject.status).to eq(:in_progress)

    subject.attempt("plain")
    expect(subject.status).to eq(:won)
  end

  it 'allows to lose' do
    expect(subject.status).to eq(:in_progress)

    subject.attempt("plaia")
    subject.attempt("plaib")
    subject.attempt("plaic")
    subject.attempt("plaid")
    subject.attempt("plaie")
    subject.attempt("plaij")
    expect(subject.status).to eq(:lost)
  end

  context 'when all letters in the right spot' do
    it 'returns a total match result' do
      expect(subject.attempt("plain")).to eq([2, 2, 2, 2, 2])
    end
  end

  context 'when some letters in the wrong spot' do
    it 'returns a partial match result' do
      expect(subject.attempt("nialp")).to eq([1, 1, 2, 1, 1])
    end
  end

  it 'returns all attempts' do
    expect(subject.attempts).to eq([])

    subject.attempt("plain")
    expect(subject.attempts).to eq([["plain", [2, 2, 2, 2, 2]]])
  end

  context 'when a word is not 5-letters long' do
    it 'raises an error' do
      expect { subject.attempt("plai") }.to raise_error(ArgumentError)
    end
  end
end
