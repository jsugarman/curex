require "hanami/cli"
require "bigdecimal"
require "money"
require "money/bank/google_currency"

require 'pry'

Money.use_i18n = false
Money.default_bank = Money::Bank::GoogleCurrency.new

module Curex
  require "curex/version"

  class CLI
    def call(*args)
      Hanami::CLI.new(Commands).call(*args)
    end

    module Commands
      extend Hanami::CLI::Registry

      class Convert < Hanami::CLI::Command
        argument :amount, required: true, desc: 'The amount to be converted'
        argument :from, required: true, desc: 'The ISO code of the amount being converted from'
        argument :to, required: true, desc: 'The ISO code the amount to convert to'

        def call(amount:, from:, to:)
          money = Money.new(amount.to_d * 100, from)
          result = money.exchange_to(to)
          # puts "converting..."
          puts "#{amount} #{from} = #{result} #{to}"
        end
      end

      class Currencies < Hanami::CLI::Command
        option :verbose, default: 'n', values: %w[y yes Y YES Yes n no N NO No], desc: "Display all currency details or just ISO code and name (default)"

        def call(**options)
          puts 'currencies...'
          # binding.pry
          verbose = options.fetch(:verbose, 'n').match?(/[y|yes]/i) ? true : false
          Money::Currency.table.values.each do |currency|
            puts "#{currency}" if verbose
            puts "#{currency[:iso_code]}, #{currency[:name]}" unless verbose
          end
        end
      end

      register "currencies", Currencies
      register "convert", Convert
    end
  end
end
