require 'test_helper'

module Utilities
  describe Cookie do
    subject { Cookie.new("JSESSIONID", "123") }

    describe "#to_command" do
      it 'converts the cookie to a cURL option' do
        subject.to_command.must_equal "--cookie \"JSESSIONID=123\""
      end
    end
  end
end
