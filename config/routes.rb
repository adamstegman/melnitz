# coding: UTF-8

Melnitz::Application.routes.draw do
  resources :emails, only: [:index, :show] do
    collection do
      get :personal
      get :issues
      get :projects
      get :ucern
    end
  end
end
