# coding: UTF-8

require 'spec_helper'

describe DashboardsController do
  render_views

  describe 'GET "index"' do
    it 'renders successfully' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET "personal"' do
    it 'renders successfully' do
      get :personal
      expect(response).to be_success
    end
  end

  describe 'GET "issues"' do
    it 'renders successfully' do
      get :issues
      expect(response).to be_success
    end
  end

  describe 'GET "projects"' do
    it 'renders successfully' do
      get :projects
      expect(response).to be_success
    end
  end

  describe 'GET "ucern"' do
    it 'renders successfully' do
      get :ucern
      expect(response).to be_success
    end
  end
end
