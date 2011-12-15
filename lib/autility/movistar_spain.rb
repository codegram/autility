# encoding: utf-8
require 'capybara'
require 'capybara/dsl'
require 'show_me_the_cookies'
require 'fileutils'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

module Autility
  # Public: A scraper for all the utility invoices in MovistarSpain.
  #
  # Examples
  #
  #   # Download the invoice from September this year and store it in /tmp.
  #   MovistarSpain.scrape("user", "password", 9, "/tmp") # Download all invoices from September this year
  #
  class MovistarSpain
    include Capybara::DSL
    include ShowMeTheCookies

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from MovistarSpain.
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
      filename = "#{@folder}/movistar_#{month}_#{@year}.pdf"
      document.save(filename)
      filename
    end

    private

    # Internal: Logs in to the MovistarSpain website.
    #
    # Returns nothing.
    def log_in
      visit "/on/pub/ServNav?servicio=home&home=personal&v_segmento=EMPR"
      fill_in "usuario", :with => @user
      fill_in "contrasenia", :with => @password
      first("#enviar").click
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document
      @document ||= begin
        invoice = nil

        cookie = Cookie.new("wacsessionid", get_me_the_cookie("wacsessionid")[:value])

        visit "https://www.movistar.es/id/priv/seg00/jsp/UFE/es/IDAA00SCUFE_1_facturas_STB.jsp?SOLDUP="

        combo = all(".combos_numerados_facturacion1")[1]
        select = combo.find(".combos_numeros")
        id = select[:id]
        options = select.all('option')

        found = options.detect do |date|
          date.text =~ /#{month}-#{@year}/
        end

        url = "https://www.movistar.es"

        if found
          select(found.text, from: id)
          find("#aceptar").click

          within_window(page.driver.browser.window_handles.last) do
            within_frame(find('frame')[:id]) do
              within_frame(find('iframe')[:id]) do
                url += find('#descargar a')[:href].gsub("javascript:CargarGuardar('","").gsub("')","")
              end
            end
          end
        else
          raise "MovistarSpain invoice for month #{month} is not available yet."
        end

        Document.new(url, :get, cookie)
      end
    end

    # Internal: Returns the String current month padded with zeros to the left.
    def month
      @month.to_s.rjust(2, '0')
    end

    # Internal: Sets the configuration for capybara to work with the MovistarSpain
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :selenium
      Capybara.app_host       = 'https://www.movistar.es'
    end
  end
end
