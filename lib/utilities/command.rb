module Utilities
  # Public: A Command is a system cURL command builder.
  #
  # Examples
  #
  #   command = Command.build(url, params, cookie, "foo.pdf")
  #   # => "curl --data ..."
  #
  module Command
    # Public: Builds a command to fetch and save a remote document via cURL.
    #
    # url    - The String url where we can get the document
    # cookie - the session Cookie needed to access the url
    # params - The Array of POST params needed to fetch it
    # path   - the String path to save the document to.
    #
    # Returns the String command ready to execute.
    def build(url, cookie, params, path)
      out = "curl --data \""

      out << params.to_a.map do |name, value|
        "#{name}=#{value}"
      end.join("&")

      out << "\""
      out << " #{cookie.to_command}" if cookie
      out << " \"#{url}\""
      out << " -o "
      out << path
      out
    end
    module_function :build
  end
end
