Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :doctors do
    resources :availabilities, except: [:new, :edit, :show], module: :doctors
  end
end
