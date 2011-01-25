module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Webpay
        class Middleware
          def initialize(app)
            @app = app
          end
          
          def call(env)
            case env['PATH_INFO']
            when '/webpay/pay'
              process(env, payment_cgi_path)
            when '/webpay/result'
              process(env, result_cgi_path)
            else
              @app.call env
            end
          end
          
          protected
            # Extracted from rack-legacy
            def process(env,cgi_path)
              raise 'Method not allowed' unless env['REQUEST_METHOD'] == 'POST'
              
              status = 200
              headers = {}
              body = ''

              stderr = Tempfile.new 'webpay-cgi-stderr'
              IO.popen('-', 'r+') do |io|
                if io.nil?  # Child
                  $stderr.reopen stderr.path
                  ENV['DOCUMENT_ROOT'] = root_path
                  env.each {|k, v| ENV[k] = v if v.respond_to? :to_str}

                  exec ENV, cgi_path
                else        # Parent
                  io.write(env['rack.input'].read) if env['rack.input']
                  io.close_write
                  until io.eof? || (line = io.readline.chomp) == ''
                    if line =~ /\s*\:\s*/
                      key, value = line.split(/\s*\:\s*/, 2)
                      if headers.has_key? key
                        headers[key] += "\n" + value
                      else
                        headers[key] = value
                      end
                    end
                  end
                  body = io.read
                  stderr.rewind
                  stderr = stderr.read
                  Process.wait
                  unless $?.exitstatus == 0
                    raise CGIExecutionError
                  end
                end
              end

              status = headers.delete('Status').to_i if headers.has_key? 'Status'
              [status, headers, [body]]
            end
            
            def root_path
              ActiveMerchant::Billing::Integrations::Webpay.cgis_root
            end
            
            def payment_cgi_path
              root_path + '/tbk_bp_pago.cgi'
            end
            
            def result_cgi_path
              root_path + '/tbk_bp_resultado.cgi'
            end
            
            def check_cgi_path
              root_path + '/tbk_check_mac.cgi'
            end
          
          class CGIExecutionError < Error; end
        end
      end
    end
  end
end
