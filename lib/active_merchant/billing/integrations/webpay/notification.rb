# encoding: utf-8
require 'active_merchant/billing/integrations/notification'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Webpay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          SUCCESS_RESPONSE = 'ACEPTADO'
          FAILURE_RESPONSE = 'RECHAZADO'
          VALID_MAC_RESPONSE = 'CORRECTO'
          
          RESPONSE_CODES = {
            '0' => 'Transacción aprobada.',
            '-1' => 'Rechazo de tx. en B24, No autorizada',
            '-2' => 'Transacción debe reintentarse.',
            '-3' => 'Error en tx.',
            '-4' => 'Rechazo de tx. En B24, No autorizada',
            '-5' => 'Rechazo por error de tasa.',
            '-6' => 'Excede cupo máximo mensual.',
            '-7' => 'Excede límite diario por transacción.',
            '-8' => 'Rubro no autorizado.'
          }
          
          def initialize(raw_post)
            super(CGI.unescape(raw_post))
          end
          
          def complete?
            valid?
          end
          
          def transaction_id
            params['TBK_ID_TRANSACCION']
          end

          # When was this payment received by the client. 
          def received_at
            Time.new(
              Time.now.year, 
              params['TBK_FECHA_TRANSACCION'][0..1].to_i, 
              params['TBK_FECHA_TRANSACCION'][2..3].to_i,
              params['TBK_HORA_TRANSACCION'][0..1].to_i,
              params['TBK_HORA_TRANSACCION'][2..3].to_i,
              params['TBK_HORA_TRANSACCION'][4..5].to_i
            )
          end

          def security_key
            params['TBK_MAC']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['TBK_MONTO'][0..-3] + '.' + params['TBK_MONTO'][-2..-1]
          end

          # The money in float format
          def amount
            params['TBK_MONTO'].to_f / 100
          end

          # Was this a test transaction?
          def test?
            params[''] == 'test'
          end

          def status
            params['TBK_RESPUESTA']
          end
          
          def session_id
            params['TBK_ID_SESION']
          end
          
          def card_number
            params['TBK_FINAL_NUMERO_TARJETA']
          end
          
          def order_id
            params['TBK_ORDEN_COMPRA']
          end
          
          def fail!(message=nil)
            @error = true
            @message = message
          end
          
          def success?
            valid? && !@error
          end
          
          def authorization
            params['TBK_CODIGO_AUTORIZACION']
          end
          
          def message
            @message || RESPONSE_CODES[params['TBK_RESPUESTA']]
          end

          # Check the transaction's validity. This method has to be called after a new 
          # apc arrives to verify it using your private key.
          # 
          # Example:
          #   
          #   def notify
          #     notify = Webpay::Notification.new(request.raw_post)
          # 
          #     if notify.valid? 
          #       if check order & ammount
          #         # Process Order
          #       else
          #         notify.fail!
          #       end
          #     else
          #       ... log possible hacking attempt ...
          #     end
          # 
          #     render :text => notify.acknowledge
          #   end
          def valid? 
            valid_mac && params['TBK_RESPUESTA'] == '0'
          end
          
          def acknowledge
            @error ? FAILURE_RESPONSE : SUCCESS_RESPONSE
          end
          
          private
            # Take the posted data and move the relevant data into a hash
            def parse(post)
              @raw = post
              for line in post.split('&')
                key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
                params[key] = value
              end
            end
            
            def valid_mac
              if @valid_mac.nil?
                file = Tempfile.new 'webpay-mac-check'
                file.write raw
                file.close
                executable = Webpay.cgis_root + '/tbk_check_mac.cgi'
                @valid_mac = ( `#{executable} #{file.path}`.strip == VALID_MAC_RESPONSE )
                file.unlink
                
                fail! 'Mac Invalido' unless @valid_mac
              end
              
              @valid_mac
            end
        end
      end
    end
  end
end
