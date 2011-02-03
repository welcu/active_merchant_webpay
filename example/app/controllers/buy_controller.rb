require "active_merchant/billing/integrations/action_view_helper"

class BuyController < ApplicationController
  helper ActiveMerchant::Billing::Integrations::ActionViewHelper
  
  def index
  end
  
  def notify
    notify = ActiveMerchant::Billing::Integrations::Webpay::Notification.new(request.raw_post)
    
    if notify.valid?  
      if true # check everything else (price order etc)
        
      else
        notify.fail!
      end
    end
      
    render :text => notify.acknowledge
  end
  
  def success
    render :text => 'SUCCESS'
  end
  
  def failure
    render :text => 'FAILURE'
  end
end
