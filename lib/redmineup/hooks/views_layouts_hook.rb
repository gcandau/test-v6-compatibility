# frozen_string_literal: true

module Redmineup
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(_context = {})
        stylesheet_link_tag(:calendars, plugin: 'redmineup') +
        stylesheet_link_tag(:money, plugin: 'redmineup')
      end
    end
  end
end
