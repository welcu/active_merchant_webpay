WebpaySpike2::Application.routes.draw do
  root :to => 'buy#index'
  
  post 'success', :to => 'buy#success'
  post 'failure', :to => 'buy#failure'
  post 'notify', :to => 'buy#notify'
end
