module Autility
  # Public: Represents a remote document we are interested in.
  #
  # Examples
  #
  #   document = Document.new(url, :post, cookie, params)
  #   document.save("~/utilities/endesa_11_2012.pdf")
  #
  class Document
    attr_reader :url, :params, :cookie

    # Public: Initializes a new document.
    #
    # url    - The String url where we can get the document
    # method - The String HTTP method to use.
    # cookie - the session Cookie needed to access the url
    # params - The Array of POST params needed to fetch it
    def initialize(url, method=:get, cookie=nil, params={})
      @url    = url
      @method = method
      @params = params
      @cookie = cookie
    end

    # Public: Fetches the document and saves it to a particular path.
    #
    # path - The String path where we will save the document.
    #
    # Returns nothing.
    def save(path)
      command = Command.build(@url, @method, @cookie, @params, path)
      system(command)
    end
  end
end
