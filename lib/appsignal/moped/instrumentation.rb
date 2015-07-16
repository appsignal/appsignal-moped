module Appsignal
  module Moped
    module Instrumentation
      EVENT_NAME = 'query.moped'

      private

      def logging_with_appsignal_instrumentation(operations, &block)
        ActiveSupport::Notifications.instrument(
          EVENT_NAME, :ops => Appsignal::Moped::Instrumentation.deep_clone(operations)
        ) do
          logging_without_appsignal_instrumentation(operations, &block)
        end
      end

      def self.deep_clone(value)
        case value
        when Hash
          result = {}
          value.each { |k, v| result[k] = deep_clone(v) }
          result
        when Array
          value.map { |v| deep_clone(v) }
        when Symbol, Numeric, Regexp, true, false, nil
          value
        else
          value.clone
        end
      end

    end
  end
end
