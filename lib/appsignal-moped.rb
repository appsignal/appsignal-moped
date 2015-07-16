require 'moped'
require 'appsignal'
require 'appsignal/moped/instrumentation'

::Moped::Node.class_eval do
  include Appsignal::Moped::Instrumentation

  private

  alias_method :logging_without_appsignal_instrumentation, :logging
  alias_method :logging, :logging_with_appsignal_instrumentation
end
