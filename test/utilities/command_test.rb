require 'test_helper'

module Utilities
  describe Command do
    let(:url) { "http://example.com/some_document.pdf" }
    let(:params) do
      { foo: "bar", baz: "yeah" }
    end
    let(:cookie) { stub(to_command: "--cookie \"JSESSIONID=123\"") }

    describe ".build" do
      it 'builds a system command' do
        command = Command.build(url, cookie, params, "foo.pdf")

        command.must_equal(
          %Q{curl --data "foo=bar&baz=yeah" --cookie "JSESSIONID=123" "http://example.com/some_document.pdf" -o foo.pdf}
        )
      end
    end
  end
end
