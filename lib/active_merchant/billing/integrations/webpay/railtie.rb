module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Webpay
        class Railtie < Rails::Railtie
          initializer "load configuration" do
            ActiveMerchant::Billing::Integrations::Webpay.cgis_root = Rails.root.join("vendor", "webpay").to_s
          end
        end
      end
    end
  end
end
