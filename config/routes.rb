require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  match "/404", to: "system#not_found", via: :all
  match "/500", to: "system#error", via: :all

  # Defines the root path route ("/")
  root "dashboards#index"
  
  get "/ingresar", to: "login_user#signin", as: :login
  post "/ingresar", to: "login_user#create", as: :login_create

  get "/otp", to: "login_user#verify", as: :otps_verify
  post "/confirm", to: "login_user#confirm", as: :login_confirm

  get '/salir' => 'login_user#logout', as: :logout

  get "/admin/ingresar", to: "login_admin#signin", as: :admin_login
  post "/admin/ingresar", to: "login_admin#create", as: :admin_login_create

  get "/admin/otp", to: "login_admin#verify", as: :admin_otps_verify
  post "/admin/confirm", to: "login_admin#confirm", as: :admin_login_confirm

  get '/admin/salir' => 'login_admin#logout', as: :admin_logout

end
