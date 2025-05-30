# frozen_string_literal: true

require 'spec_helper'

describe Uncruft::Warning do
  before do
    stub_const('Warning', Kernel) unless defined?(Warning)
  end

  it "doesn't block generic warnings" do
    expect(Uncruft.deprecator).not_to receive(:warn)
    warn
    warn('oh no, you should worry')
    Kernel.warn
    Kernel.warn('oh no, you should worry')
    Warning.warn('oh no, you should worry')
  end

  it "accepts kwargs from Kernel.warn" do # rubocop:disable RSpec/NoExpectationExample
    warn(uplevel: 1)
    warn('oh no, you should worry', uplevel: 1)
    Kernel.warn(uplevel: 1)
    Kernel.warn('oh no, you should worry', uplevel: 1)
  end

  context 'when warning includes the word "deprecation" or "deprecated"' do
    it 'treats it as a deprecation warning' do
      expect(Uncruft.deprecator).to receive(:warn).and_return('banana').exactly(6).times
      expect(warn('[dEpReCaTiOn] oh no, you should worry')).to eq 'banana'
      expect(Kernel.warn('[dEpReCaTiOn] oh no, you should worry')).to eq 'banana'
      expect(Warning.warn('[dEpReCaTiOn] oh no, you should worry')).to eq 'banana'
      expect(warn('oh no, this is DePrEcAtEd, so you should worry')).to eq 'banana'
      expect(Kernel.warn('oh no, this is DePrEcAtEd, so you should worry')).to eq 'banana'
      expect(Warning.warn('oh no, this is DePrEcAtEd, so you should worry')).to eq 'banana'
    end

    context 'and when warning includes caller info' do
      it 'strips out the path so that Uncruft.deprecator can append a new one' do
        path = caller_locations(0..0).first.path

        allow(Uncruft.deprecator).to receive(:warn).with('foo is deprecated!').and_return('hurray')
        expect(warn("#{path}: foo is deprecated!")).to eq('hurray')

        allow(Uncruft.deprecator).to receive(:warn).with('[DEPRECATION] bar is no more.').and_return('huzzah')
        expect(Kernel.warn("[DEPRECATION] bar is no more. #{path}:#{caller_locations(0..0).first.lineno}")).to eq('huzzah')

        allow(Uncruft.deprecator).to receive(:warn).with('Deprecation detected: banana --').and_return('we do our best...')
        expect(Warning.warn("Deprecation detected: banana -- #{caller(0..0).first}")).to eq('we do our best...')
      end
    end
  end
end
