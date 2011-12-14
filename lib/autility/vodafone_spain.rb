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
      visit "/cpar/do/home/loginVodafone?type=empresas"
      fill_in "user", :with => @user
      fill_in "pass", :with => @password
      first(".botonera_entrar #login").click
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document
      @document ||= begin
        invoice = nil

        visit "https://areaclientes.vodafone.es/cwgc/do/ebilling/get?ebplink=/tbmb/main/dashboard/invoices.do"

        within "table#recent_invoices_tab1" do
          row = all("tr").detect do |tr|
            tr.text =~ /-#{month}-#{@year}/
          end
          invoice = row.find('#scriptOnly a')
        end

        raise "VodafoneSpain invoice for month #{month} is not available yet." unless invoice

        url = "https://b2b.ebilling.vodafone.es/tbmb"
        url += invoice[:onclick].gsub("downloadDocument('", '')[0..-2]

        p url

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
