# coding: UTF-8

Melnitz::Application.routes.draw do
  root to: 'dashboards#index'
  get 'personal' => 'dashboards#personal'
  get 'issues' => 'dashboards#issues'
  get 'projects' => 'dashboards#projects'
  get 'ucern' => 'dashboards#ucern'

  resources :emails, only: [:index, :show] do
    collection do
      get :personal
      get :issues
      get :projects
      get :ucern
    end
    member do
      get :body
    end
  end

  namespace :crucible do
    resources :reviews, only: [:show]
  end

  namespace :jira do
    resources :issue, only: [:show]
  end

  mount Kss::Engine => '/styles' if defined? Kss
end
