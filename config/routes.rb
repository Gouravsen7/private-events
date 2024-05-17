Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "events#index"

  resource :user, only: :show
  resources :requests, only: %i[new create] do
    get :attendee_requests, on: :collection
    get :owner_requests, on: :collection
    post :bulk_create, on: :collection
    patch :approve, on: :member
    patch :reject, on: :member
  end

  resources :events do
    member do
      delete :leave
    end
  end
end
