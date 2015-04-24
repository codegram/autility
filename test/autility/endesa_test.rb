# encoding: utf-8
require_relative '../test_helper'

module Autility
  describe Endesa do
    subject { Endesa.new("foo", "bar", 11, "/tmp/utilities") }

    describe ".scrape" do
      it 'delegates to an instance' do
        Endesa.any_instance.expects(:scrape)
        Endesa.scrape("foo", "bar", 11, "/tmp/utilities")
      end
    end

    describe '#scrape' do
      it 'gets the document in' do
        subject.expects(:setup_capybara)
        subject.expects(:log_in)
        document = Document.new(url = stub, cookie = stub, {})
        subject.expects(:document).returns(document)
        document.expects(:save)

        month = 11
        year  = Time.now.year

        subject.scrape.must_equal "/tmp/utilities/endesa_#{month}_#{year}.pdf"
      end
    end
  end
end
