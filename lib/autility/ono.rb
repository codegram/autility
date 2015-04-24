# encoding: utf-8
require 'capybara'
require 'capybara/dsl'
require 'show_me_the_cookies'
require 'fileutils'

module Autility
  # Public: A scraper for all the utility invoices in Ono.
  #
  # Examples
  #
  #   # Download the invoice from September this year and store it in /tmp.
  #   Ono.scrape("user", "password", 9, "/tmp") # Download all invoices from September this year
  #
  class Ono
    include Capybara::DSL
    include ShowMeTheCookies

    MONTHS = %w(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from Ono.
    #
    # Returns nothing.
    def self.scrape(*args)
      new(*args).scrape
    end

    def initialize(user, password, month, folder)
      @user     = user
      @password = password
      @month    = month
      @human_month = MONTHS[month - 1]
      @folder   = folder
      @year     = Time.now.year
    end

    # Public: Scrapes the ono website and gets the invoice for the current
    # month, saving it to @folder.
    #
    # Returns the String path of the saved document.
    def scrape
      setup_capybara
      log_in

      FileUtils.mkdir_p(@folder)
      filename = "#{@folder}/ono_#{month}_#{@year}.pdf"
      document.save(filename)
      filename
    end

    private

    # Internal: Logs in to the Ono website.
    #
    # Returns nothing.
    def log_in
      visit "https://www.ono.es/clientes/facturacion/facturas-emitidas/"
      within '#loginUsuario' do
        fill_in "user_username", :with => @user
        fill_in "user_password", :with => @password
        click_button("Iniciar Sesión")
      end
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document
      @document ||= begin
                      row = all('.factura-emitida').detect { |ul| ul.text =~ /#{@human_month} de #{@year}/ }
                      raise "Ono invoice for month #{month} is not available yet." unless row
                      path = within row do
                        find('a.descargar-factura')[:onclick].scan(/href = '([^']+)'/).flatten.first
                      end

                      url = "https://www.ono.es" + path

                      cookie = Cookie.new('JSESSIONID', get_me_the_cookie('JSESSIONID')[:value])
                      Document.new(url, :get, cookie)
      end
    end

    # Internal: Returns the String current month padded with zeros to the left.
    def month
      @month.to_s.rjust(2, '0')
    end

    # Internal: Sets the configuration for capybara to work with the Ono
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :selenium
      Capybara.app_host       = 'https://www.ono.es'
    end
  end
end
