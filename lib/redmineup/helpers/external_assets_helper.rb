module Redmineup
  module ExternalAssetsHelper
    include ActionView::Helpers::JavaScriptHelper

    def select2_assets
      return if @select2_tag_included
      @select2_tag_included = true
      javascript_include_tag('select2', plugin: GEM_NAME) +
        stylesheet_link_tag('select2', plugin: GEM_NAME) +
        javascript_include_tag('select2_helpers', plugin: GEM_NAME)
    end

    def chartjs_assets
      return if @chartjs_tag_included
      @chartjs_tag_included = true
      javascript_include_tag('chart.min', plugin: GEM_NAME)
    end

  end
end
