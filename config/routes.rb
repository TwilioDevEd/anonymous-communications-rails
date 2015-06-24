Rails.application.routes.draw do

  resources :vacation_properties, :path => "/properties"

  get "users/verify", to: 'users#show_verify', as: 'verify'
  post "users/verify"
  post "users/resend"

  resources :reservations, only: [:new, :create]

  resources :users, only: [:new, :create, :show]

  # Home page
  root 'main#index'

end