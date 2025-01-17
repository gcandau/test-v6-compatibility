module Redmineup
  class Currency
    module Loader
      DATA_PATH = File.expand_path("../../../../config", __FILE__)

      # Loads and returns the currencies stored in JSON files
      # in the config directory.
      #
      # @return [Hash]
      def load_currencies
        parse_currency_file('currency_iso.json')
      end

      private

      def parse_currency_file(filename)
        json = File.read("#{DATA_PATH}/#{filename}")
        json.force_encoding(::Encoding::UTF_8) if defined?(::Encoding)
        JSON.parse(json, symbolize_names: true)
      end
    end
  end
end
