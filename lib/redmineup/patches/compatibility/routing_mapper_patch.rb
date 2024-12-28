module Redmineup
  module Patches
    module Compatibility
      module RoutingMapperPatch
        def self.included(base)
          base.send(:include, InstanceMethods)

          base.class_eval do
            alias_method :constraints_without_redmineup, :constraints
            alias_method :constraints, :constraints_with_redmineup
          end
        end

        module InstanceMethods
          def constraints_with_redmineup(options = {}, &block)
            return constraints_without_redmineup(options, &block) unless options.is_a?(Hash)

            options[:object_type] = /.+/ if options[:object_type] && options[:object_type].is_a?(Regexp)
            constraints_without_redmineup(options, &block)
          end
        end
      end
    end
  end
end

unless ActionDispatch::Routing::Mapper.included_modules.include?(Redmineup::Patches::Compatibility::RoutingMapperPatch)
  ActionDispatch::Routing::Mapper.send(:include, Redmineup::Patches::Compatibility::RoutingMapperPatch)
end
