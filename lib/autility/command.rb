module Autility
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
    # method - the String HTTP method to use.
    # cookies - the session Cookies needed to access the url
    # params - The Array of POST params needed to fetch it
    # path   - the String path to save the document to.
    #
    # Returns the String command ready to execute.
    def build(url, method, cookies, params, path)
      out = "curl"

      if method == :post
        out = "curl --data \""

        out << params.to_a.map do |name, value|
          "#{name}=#{value}"
        end.join("&")

        out << "\""
      end

      if Array === cookies && cookies.any?
        out << %Q{ --cookie "#{cookies.map(&:to_command).join('; ')}"}
      elsif cookies.is_a?(Cookie)
        out << %Q{ --cookie "#{cookies.to_command}"}
      end

      out << " \"#{url}\""
      out << " -o "
      out << path
      puts out
      out
    end
    module_function :build
  end
end
