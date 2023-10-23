require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  match "/404", to: "system#not_found", via: :all
  match "/500", to: "system#error", via: :all

  # Defines the root path route ("/")
  root "dashboards#index"
  get "/ingresar", to: "auth#signin", as: :login
  post "/ingresar", to: "auth#create", as: :login_create

  get "/otp", to: "auth#verify", as: :otps_verify
  post "/confirm", to: "auth#confirm", as: :login_confirm

  get '/salir' => 'auth#logout', as: :logout
  #delete '/salir' => 'auth#logout', as: :logout
end
