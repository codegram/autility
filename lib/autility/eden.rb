# encoding: utf-8
require 'capybara'
require 'capybara/dsl'
require 'show_me_the_cookies'
require 'fileutils'

module Autility
  # Public: A scraper for all the utility invoices in Eden.
  #
  # Examples
  #
  #   # Download the invoice from September this year and store it in /tmp.
  #   Eden.scrape("user", "password", 9, "/tmp") # Download all invoices from September this year
  #
  class Eden
    include Capybara::DSL
    include ShowMeTheCookies

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from Eden.
    #
    # Returns nothing.
    def self.scrape(*args)
      new(*args).scrape
    end

    def initialize(user, password, month, folder)
      @user     = user
      @password = password
      @month    = month
      @folder   = folder
      @year     = Time.now.year
    end

    # Public: Scrapes the eden website and gets the invoice for the current
    # month, saving it to @folder.
    #
    # Returns the String path of the saved document.
    def scrape
      setup_capybara
      log_in

      FileUtils.mkdir_p(@folder)
      filename = "#{@folder}/eden_#{month}_#{@year}.pdf"
      document.save(filename)
      filename
    end

    private

    # Internal: Logs in to the Eden website.
    #
    # Returns nothing.
    def log_in
      visit "https://customerzone.edensprings.com/EdenSpringsWeb/jsp/index.jsp?phpLang=ESes"
      within 'form:nth-of-type(1)' do
        fill_in "userName", :with => @user
        fill_in "password", :with => @password
        find('input[type=image]').click
      end
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document
      @document ||= begin
                      visit "https://customerzone.edensprings.com/EdenSpringsWeb/action/buildInvoicesArchive"
                      row = all('tr').detect { |tr| tr.text =~ /#{month}\/#{@year}/ }
                      raise "Eden invoice for month #{month} is not available yet." unless row
                      within row do
                        find('a.BillArchiveText').click
                      end

                      url = "https://customerzone.edensprings.com/EdenSpringsWeb/action/billInPDF.pdf"

                      cookie = Cookie.new('JSESSIONID', get_me_the_cookie('JSESSIONID')[:value])
                      Document.new(url, :get, cookie)
      end
    end

    # Internal: Returns the String current month padded with zeros to the left.
    def month
      @month.to_s.rjust(2, '0')
    end

    # Internal: Sets the configuration for capybara to work with the Eden
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :selenium
      Capybara.app_host       = 'https://customerzone.edensprings.com'
    end
  end
end
