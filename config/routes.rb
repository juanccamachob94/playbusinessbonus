Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/:user_id', to: 'application#bonus_calculation'
  get '/alternative/:user_id', to: 'application#bonus_calculation_alternative'
end
