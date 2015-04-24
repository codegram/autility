# encoding: utf-8
require 'capybara'
require 'capybara/dsl'
require 'fileutils'

module Autility
  # Public: A scraper for all the utility invoices in VodafoneSpain.
  #
  # Examples
  #
  #   # Download the invoice from September this year and store it in /tmp.
  #   VodafoneSpain.scrape("user", "password", 9, "/tmp") # Download all invoices from September this year
  #
  class VodafoneSpain
    include Capybara::DSL

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from VodafoneSpain.
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

    # Public: Scrapes the vodafone website and gets the invoice for the current
    # month, saving it to @folder.
    #
    # Returns the String path of the saved document.
    def scrape
      setup_capybara
      log_in

      FileUtils.mkdir_p(@folder)
      filename = "#{@folder}/vodafone_#{month}_#{@year}.pdf"
      document.save(filename)
      filename
    end

    private

    # Internal: Logs in to the VodafoneSpain website.
    #
    # Returns nothing.
    def log_in
      visit "https://www.vodafone.es/autonomos/es/"
      form = find('#loginForm')
      within '#loginForm' do
        fill_in "uuid", :with => @user
        fill_in "password", :with => @password
        click_link("Entrar")
      end
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document
      @document ||= begin
                      within '.mainNav' do
                        click_link("Facturación")
                        click_link("Consulta de facturas")
                      end
                      click_link("Invoice history")

                      row = within "table#recent_invoices_tab1" do
                        all("tr").detect do |tr|
                          tr.text =~ /-#{month}-#{@year}/
                        end
                      end

                      url = within row do
                        click_link "PDF"
                        find('iframe')[:src]
                      end

                      Document.new(url)
      end
    end

    # Internal: Returns the String current month padded with zeros to the left.
    def month
      @month.to_s.rjust(2, '0')
    end

    # Internal: Sets the configuration for capybara to work with the VodafoneSpain
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :selenium
      Capybara.app_host       = 'https://canalonline.vodafone.es'
    end
  end
end
