module Waffle
  module Encoders
    module Noop
      module_function
      def encode message
        message
      end

      def decode message
        message
      end
    end
  end
end
