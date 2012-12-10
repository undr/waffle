module Waffle
  module Encoders
    module Json
      module_function
      def encode message
        ::MultiJson.encode(message)
      end

      def decode message
        ::MultiJson.decode(message)
      end
    end
  end
end
