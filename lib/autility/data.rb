module Autility
  # Public: Represents a remote document we are interested in.
  #
  # Examples
  #
  #   document = Document.new(url, params, cookie)
  #   document.save("~/utilities/endesa_11_2012.pdf")
  #
  class Document
    # Public: Initializes a new document.
    #
    # url - The String url where we can get the document
    # params - The Array of POST params needed to fetch it
    # cookie  - the session Cookie needed to access the url
    def initialize(url, params, cookie)
      @url    = url
      @params = params
      @cookie = cookie
    end
  end
end
