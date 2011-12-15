# encoding: utf-8
require 'capybara'
require 'capybara/dsl'
require 'show_me_the_cookies'
require 'fileutils'
require 'pry'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end
Capybara.default_wait_time = 20
Capybara.ignore_hidden_elements = false

module Autility
  # Public: A scraper for all the utility invoices in LaCaixa.
  #
  # Examples
  #
  #   # Download the invoice from September this year and store it in /tmp.
  #   LaCaixa.scrape("user", "password", 9, "/tmp") # Download all invoices from September this year
  #
  class LaCaixa
    include Capybara::DSL
    include ShowMeTheCookies

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from LaCaixa.
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

    # Public: Scrapes the lacaixa website and gets the invoice for the current
    # month, saving it to @folder.
    #
    # Returns the String path of the saved document.
    def scrape(index=nil)
      setup_capybara
      log_in

      FileUtils.mkdir_p(@folder)
      if index
        filename = "#{@folder}/lacaixa_#{month}_#{@year}__#{index}.pdf"
        document(index).save(filename)
      else
        return document
      end
      filename
    end

    private

    # Internal: Logs in to the LaCaixa website.
    #
    # Returns nothing.
    def log_in
      visit "/home/empreses_ca.html"
      fill_in "u", :with => @user
      fill_in "p", :with => @password
      first(".loginbut").click
    end

    # Internal: Gets the latest invoice and returns it as a Document (not
    # fetched yet).
    #
    # Returns the Document to be fetched.
    def document(index=nil)
      @document ||= begin
        params = {}
        url = "https://loc6.lacaixa.es"

        wait_until { find('frame') }

        within_frame(all('frame')[1][:name]) do
          within_frame(find('frame')[:name]) do
            find('#buzon1.msn a').click
          end
        end

        wait_until { find('frame') }

        within_frame(all('frame')[1][:name]) do
          within_frame('Cos') do
            sleep 3
            find("#lbl_Varios a").click
            sleep 3
            wait_until { find('#enlaceDescr') }
            rows = all('.table_generica tr').select do |tr|
              tr.find("td").text =~ /#{month}\/#{@year}/
            end

            if index
              rows[index].find("a").click
            else
              docs = []
              rows.each_with_index do |row, idx|
                scraper = LaCaixa.new(@user, @password, @month, @folder)
                docs << scraper.scrape(idx)
              end
              return docs
            end
          end
        end

        wait_until { find('frame') }

        within_frame(all('frame')[1][:name]) do
          within_frame('Cos') do
            within_frame("Fr1") do
              url = find("form[name=\"datos\"]")[:action]
              within("form[name=\"datos\"]") do
                guardar = {
                  "PN" => "COM",
                  "PE" => "39",
                  "RESOLUCION" => "300",
                  "CANAL_MOVIMIENTO" => "INT",
                  "target" => "Fr1",
                  "PAGINA_SOLICITADA" => "00001",
                  "FLAG_PDF_INICIAL" => "S",
                  "FLUJO" => "COM,10,:COM,51:SCP,23:GFI,7,''",
                  "CLICK_ORIG" => "FLX_COM_4",
                  "OPCION" => ""
                }

                params = all('input').reduce({}) do |h, i|
                  h.update({ i[:name] => i[:value] })
                end.update(guardar)
              end
            end
          end
        end

        Capybara.app_host = "https://loc6.lacaixa.es"
        cookie = Cookie.new("JSESSIONID_CTX", get_me_the_cookie("JSESSIONID_CTX")[:value])

        Document.new(url, :post, cookie, params)
      end
    end

    # Internal: Returns the String current month padded with zeros to the left.
    def month
      @month.to_s.rjust(2, '0')
    end

    # Internal: Sets the configuration for capybara to work with the LaCaixa
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :selenium
      Capybara.app_host       = 'http://empresa.lacaixa.es'
      Capybara.default_wait_time = 20
      Capybara.ignore_hidden_elements = false
    end
  end
end
