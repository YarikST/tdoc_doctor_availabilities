Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :doctors, module: :doctors do
    resources :working_hours, except: [:new, :edit, :show]
    resources :appointments, except: [:new, :edit, :show]
    resources :availabilities, only: :index
  end
end
