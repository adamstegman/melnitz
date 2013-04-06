# coding: UTF-8

module ApplicationHelper
  # Public: Returns the "active" class name if the given route is the requested route.
  def active_class_name(route)
    params[:action] == route ? 'active' : ''
  end
end
