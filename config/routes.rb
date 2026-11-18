Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Agent side
  resources :tickets, only: %i[index show update] do
    resources :messages, only: :create
  end
  resources :canned_replies, except: :show

  # Customer portal: reached by the private link in every email
  namespace :portal do
    resources :tickets, only: :show, param: :token do
      resources :messages, only: :create
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "tickets#index"
end
