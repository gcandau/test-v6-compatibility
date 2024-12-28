require 'active_record'
require 'action_view'

require 'redmineup/version'
require 'redmineup/engine'

require 'redmineup/settings'
require 'redmineup/settings/money'

require 'redmineup/acts_as_list/list'
require 'redmineup/acts_as_taggable/tag'
require 'redmineup/acts_as_taggable/tag_list'
require 'redmineup/acts_as_taggable/tagging'
require 'redmineup/acts_as_taggable/up_acts_as_taggable'
require 'redmineup/acts_as_viewed/up_acts_as_viewed'
require 'redmineup/acts_as_votable/up_acts_as_votable'
require 'redmineup/acts_as_votable/up_acts_as_voter'
require 'redmineup/acts_as_votable/vote'
require 'redmineup/acts_as_votable/voter'
require 'redmineup/acts_as_draftable/up_acts_as_draftable'
require 'redmineup/acts_as_draftable/draft'
require 'redmineup/acts_as_priceable/up_acts_as_priceable'

require 'redmineup/currency'
require 'redmineup/helpers/tags_helper'
require 'redmineup/money_helper'
require 'redmineup/colors_helper'

require 'liquid'
require 'redmineup/liquid/filters/additional'
require 'redmineup/liquid/filters/base'
require 'redmineup/liquid/filters/arrays'
require 'redmineup/liquid/filters/colors'
require 'redmineup/liquid/drops/issues_drop'
require 'redmineup/liquid/drops/news_drop'
require 'redmineup/liquid/drops/projects_drop'
require 'redmineup/liquid/drops/users_drop'
require 'redmineup/liquid/drops/time_entries_drop'
require 'redmineup/liquid/drops/attachment_drop'
require 'redmineup/liquid/drops/issue_relations_drop'

require 'redmineup/helpers/external_assets_helper'
require 'redmineup/helpers/form_tag_helper'
require 'redmineup/helpers/calendars_helper'
require 'redmineup/assets_manager'

require 'redmineup/patches/liquid_patch'

module Redmineup
  GEM_NAME = 'redmineup'.freeze

  def self.plugin_installed?(plugin_id)
    Rails.root.join("plugins/#{plugin_id}/init.rb").exist?
  end
end

require 'application_record' unless defined?(ApplicationRecord)

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Redmineup::ActsAsList::List
  ActiveRecord::Base.extend(Redmineup::ActsAsVotable::Voter)
  ActiveRecord::Base.extend(Redmineup::ActsAsVotable::Votable)
end

if defined?(Propshaft::Assembly)
  Propshaft::Assembly.prepend(Module.new do
    def initialize(config)
      base_dir = Pathname.new(Redmineup::AssetsManager.base_path)
      paths = Redmineup::AssetsManager.assets_paths.map { |path| Pathname.new(path)}
      asset_prefix = "plugin_assets/#{Redmineup::GEM_NAME}"

      config[:redmine_extension_paths] << Redmine::AssetPath.new(base_dir, paths, asset_prefix)
      super
    end
  end)
else
  Redmineup::AssetsManager.install_assets
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, Redmineup::CalendarsHelper
  ActionView::Base.send :include, Redmineup::ExternalAssetsHelper
  ActionView::Base.send :include, Redmineup::FormTagHelper
end

def requires_redmineup(arg)
  def compare_versions(requirement, current)
    raise ArgumentError.new('wrong version format') unless check_version_format(requirement)

    requirement = requirement.split('.').collect(&:to_i)
    requirement <=> current.slice(0, requirement.size)
  end

  def check_version_format(version)
    version =~ /^\d+.?\d*.?\d*$/m
  end

  arg = { version_or_higher: arg } unless arg.is_a?(Hash)
  arg.assert_valid_keys(:version, :version_or_higher)

  current = Redmineup::VERSION.split('.').map { |x| x.to_i }
  arg.each do |k, req|
    case k
    when :version_or_higher
      raise ArgumentError.new(':version_or_higher accepts a version string only') unless req.is_a?(String)

      unless compare_versions(req, current) <= 0
        Rails.logger.error "\033[31m[ERROR]\033[0m Redmine requires redmineup gem version #{req} or higher (you're using #{Redmineup::VERSION}).\n\033[31m[ERROR]\033[0m Please update with 'bundle update redmineup'." if Rails.logger
        abort "\033[31mRedmine requires redmineup gem version #{req} or higher (you're using #{Redmineup::VERSION}).\nPlease update with 'bundle update redmineup'.\033[0m"
      end
    when :version
      req = [req] if req.is_a?(String)
      if req.is_a?(Array)
        unless req.detect { |ver| compare_versions(ver, current) == 0 }
          abort "\033[31mRedmine requires redmineup gem version #{req} (you're using #{Redmineup::VERSION}).\nPlease update with 'bundle update redmineup'.\033[0m"
        end
      elsif req.is_a?(Range)
        unless compare_versions(req.first, current) <= 0 && compare_versions(req.last, current) >= 0
          abort "\033[31mRedmine requires redmineup gem version between #{req.first} and #{req.last} (you're using #{Redmineup::VERSION}).\nPlease update with 'bundle update redmineup'.\033[0m"
        end
      else
        raise ArgumentError.new(':version option accepts a version string, an array or a range of versions')
      end
    end
  end
  true
end
