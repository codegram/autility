# encoding: utf-8
require 'capybara'
require 'capybara/dsl'
require 'show_me_the_cookies'
require 'fileutils'

module Autility
  # Public: A scraper for all the utility invoices i Endesa.
  #
  # Examples
  #
  #   # Download the invoice from September this year and store it in /tmp.
  #   Endesa.scrape("user", "password", 9, "/tmp") # Download all invoices from September this year
  #
  class Endesa
    include Capybara::DSL
    include ShowMeTheCookies

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from Endesa.
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

    # Public: Scrapes the endesa website and gets the invoice for the current
    # month, saving it to @folder.
    #
    # Returns the String path of the saved document.
    def scrape
      setup_capybara
      log_in

      FileUtils.mkdir_p(@folder)
      filename = "#{@folder}/endesa_#{month}_#{@year}.pdf"
      document.save(filename)
      filename
    end

    private

    # Internal: Logs in to the Endesa website.
    #
    # Returns nothing.
    def log_in
      visit "/gp/login.do"
      fill_in "id",    :with => @user
      fill_in "clave", :with => @password
      first(".bLogin a").click
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document
      @document ||= begin
                      visit "https://www.gp.endesaonline.com/gp/GenericForward.do?TO=obtenerBuscadorFacturasGP"
                      rows = all("#listado_facturas tr").to_a
                      rows.shift # header

                      row = rows.detect do |row|
                        date = row.all('td')[6].text
                        date =~ %r{\d{2}/#{month.to_i}/\d{2}}
                      end

                      invoice = row.first('a')

                      raise "Endesa invoice for month #{month} is not available yet." unless invoice

                      cd_cfactura, cd_contrext, estado, secfactu, creffact, sfecha, sPos = invoice[:href].scan(/descargarPDFFactura\(([^\)]+)\)/).flatten.first.split(",").map { |s| s[1..-2] }
                      url = "https://www.gp.endesaonline.com/gp/GenericForward.do?TO=GenerarFacturas&CFACTURA=" + cd_cfactura +"&SECFACTU="+ secfactu +"&CREFFACT=" + creffact+ "&SFECHA=" + sfecha+"&ESTADO=" + estado + "&pos=" + sPos
                      cookie = Cookie.new('JSESSIONID', get_me_the_cookie('JSESSIONID')[:value])
                      Document.new(url, :get, cookie)
                    end
    end

    # Internal: Hack for ShowMeTheCookies.
    def driver
      Capybara.current_driver
    end

    # Internal: Hack for ShowMeTheCookies.
    def drivers
      send :adapters
    end

    # Internal: Returns the String current month padded with zeros to the left.
    def month
      @month.to_s.rjust(2, '0')
    end

    # Internal: Sets the configuration for capybara to work with the Endesa
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :selenium
      Capybara.app_host       = 'https://www.gp.endesaonline.com'
    end
  end
end
