require 'spec_helper'
require_relative '../../app/game'
require_relative '../../app/game/dictionary/test'

describe Game do
  subject { described_class.new(::Game::Dictionary::Test.new(["plain"],
                                                             ["plain","plaia","plaib","plaic","plaid","plaie","plaij"])) }

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

    it 'does not match for the same letter twice' do
      expect(subject.attempt("plaia")).to eq([2, 2, 2, 2, 0])
      expect(subject.attempt("alain")).to eq([0, 2, 2, 2, 2])
      expect(subject.attempt("aliin")).to eq([1, 2, 0, 2, 2])
      expect(subject.attempt("aliia")).to eq([1, 2, 0, 2, 0])
      expect(subject.attempt("aaiia")).to eq([1, 0, 0, 2, 0])
    end
  end

  context 'word with the same letters in different positions' do
    subject { described_class.new(::Game::Dictionary::Test.new(["banaa"], [])) }

    it 'does a partial matching properly' do
      expect(subject.attempt("aanan")).to eq([1, 2, 2, 2, 0])
      expect(subject.attempt("aonan")).to eq([1, 0, 2, 2, 0])
      expect(subject.attempt("banan")).to eq([2, 2, 2, 2, 0])
      expect(subject.attempt("banaa")).to eq([2, 2, 2, 2, 2])
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

  it 'checks if a word is available in the dictionary' do
    expect(subject.word_available?("plain")).to be_truthy
    expect(subject.word_available?("not_plain")).to be_falsey
  end
end
