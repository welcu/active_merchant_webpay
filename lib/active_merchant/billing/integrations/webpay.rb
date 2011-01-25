module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Webpay 
        mattr_accessor :service_url       
        self.service_url = '/webpay/pay'
        
        mattr_accessor :cgis_root
        self.cgis_root = 'vendor/webpay'

        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end

require "active_merchant/billing/integrations/webpay/version"
require "active_merchant/billing/integrations/webpay/helper"
require "active_merchant/billing/integrations/webpay/notification"
require "active_merchant/billing/integrations/webpay/middleware"
require "active_merchant/billing/integrations/webpay/railtie" if defined? Rails
