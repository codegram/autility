# utilities

A scraper that downloads PDF invoices from utility vendors. That's it.

It will focus mainly on spanish vendors, but pull requests will be accepted
to support as many vendors as possible.

For now it supports downloading invoices from Endesa and Vodafone Spain.

## Install

    $ gem install utilities

## Usage

    $ utilities VENDOR --user USER --password PASSWORD [--month MONTH] [--output-folder OUTPUT_FOLDER]
    $ utilities --help
    $ utilities --help endesa
    $ utilities --help vodafone

## Examples

Downloading the Endesa invoice for the current month:

    $ utilities endesa --user john --password doe

Downloading the Vodafone invoice for the past October and save it to ~/billing:

    $ utilities vodafone --user john --password doe --month 10 --output-folder ~/billing

## Parsing the output

The output is simple, thus parseable by UNIX tools such as grep or awk. It
looks like this:

    Path: /Users/john/billing/vodafone_10_2011.pdf

For example, to open the file right after downloading it:

    $ open `utilities endesa --user john --password doe | grep Path: | awk '{print $2}'`

## License

Released under the MIT License.
Copyright 2011 [Codegram Technologies](http://codegram.com)
