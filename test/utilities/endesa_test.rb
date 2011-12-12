# encoding: utf-8
require_relative '../test_helper'

module Utilities
  describe Endesa do
    subject { Endesa.new }

    before do
      subject.setup_capybara
    end

    describe ".scrape" do
      it 'delegates to an instance' do
        Endesa.stubs(:new).returns subject
        subject.expects(:scrape)

        Endesa.scrape
      end
    end
  end
end
