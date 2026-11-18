Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Agent side
  resources :tickets, only: %i[index show update] do
    resources :messages, only: :create
    resources :taggings, only: %i[create destroy]
  end
  resources :canned_replies, except: :show
  resources :saved_views, only: %i[create destroy]
  resources :agents, only: %i[index new create update destroy]
  resources :invitations, only: %i[edit update], param: :token

  # Customer portal: reached by the private link in every email
  namespace :portal do
    resources :tickets, only: :show, param: :token do
      resources :messages, only: :create
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "tickets#index"
end
