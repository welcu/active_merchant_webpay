require 'active_merchant/billing/integrations/helper'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Webpay
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          def initialize(order, account, options={})
            super
            # Webpay expects the amount in "cents"
            self.amount = (options[:amount]*100).to_i
            add_field('TBK_TIPO_TRANSACCION', 'TR_NORMAL')
          end
          
          mapping :amount, 'TBK_MONTO'
          mapping :session, 'TBK_ID_SESION'
        
          mapping :order, 'TBK_ORDEN_COMPRA'
          mapping :return_url, 'TBK_URL_EXITO'
          mapping :cancel_return_url, 'TBK_URL_FRACASO'
        end
      end
    end
  end
end
