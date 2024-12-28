module Redmineup
  module Patches
    module Compatibility
      module UserPatch
        def self.included(base)
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def atom_key
            rss_key
          end
        end
      end
    end
  end
end

unless ActionDispatch::Routing::Mapper.included_modules.include?(Redmineup::Patches::Compatibility::UserPatch)
  ActionDispatch::Routing::Mapper.send(:include, Redmineup::Patches::Compatibility::UserPatch)
end
