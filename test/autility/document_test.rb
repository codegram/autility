require 'test_helper'

module Autility
  describe Document do
    describe "#save" do
      let(:url) { stub }
      let(:params) { stub }
      let(:cookie) { stub }

      subject { Document.new(url, :get, cookie, params) }

      it "fetches the document and saves it to a path" do
        Command.stubs(:build).with(url, :get, cookie, params, "foo.pdf").returns command = stub
        subject.expects(:system).with command
        subject.save("foo.pdf")
      end
    end
  end
end
