require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

module Utilities
  # Public: A scraper for all the utility invoices i Endesa.
  #
  # Examples
  #
  #   Endesa.scrape(9, 2011) # Download all invoices from September 2011
  #   Endesa.scrape(9) # Download all invoices from September this year
  #   Endesa.scrape # Download all invoices from the current month.
  #
  class Endesa
    include Capybara::DSL

    # Public: Instantiates a new scraper and fires it to download the utility
    # invoices from Endesa.
    #
    # Returns nothing.
    def self.scrape
      new.scrape
    end

    # Internal: Sets the configuration for capybara to work with the Endesa
    # website.
    #
    # Returns nothing.
    def setup_capybara
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.app_host       = 'https://www.gp.endesaonline.com'
    end

    def scrape
    end
  end
end
