# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'base64'
require "active_merchant/billing/integrations/webpay/version"

Gem::Specification.new do |s|
  s.name        = "active_merchant_webpay"
  s.version     = ActiveMerchant::Billing::Integrations::Webpay::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sebastián Gamboa"]
  s.email       = [Base64.decode64("c2ViYUB3ZWxjdS5jb20=\n")]
  s.homepage    = ""
  s.summary     = %q{ActiveMerchant integration for Transbank's Webpay service}
  s.description = %q{ActiveMerchant integration for Transbank's Webpay service}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('activemerchant', '~> 1.10.0')
end
