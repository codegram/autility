module Utilities
  # Public: Represents a browser cookie.
  #
  # Examples
  #
  #   cookie = Cookie.new("JSESSIONID", "123")
  #   cookie.to_command
  #   # => "--cookie \"JSESSIONID=123\""
  #
  class Cookie < Struct.new(:name, :value)
    # Public: Converts the cookie to a cURL option.
    #
    # Returns the String cURL option.
    def to_command
      %Q(--cookie "#{name}=#{value}")
    end
  end
end
