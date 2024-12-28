module Redmineup
  module Patches
    module Compatibility
      module ApplicationControllerPatch
        def self.included(base) # :nodoc:
          base.extend(ClassMethods)
          base.class_eval do
            unloadable # Send unloadable so it will not be unloaded in development
          end
        end

        module ClassMethods
          def before_action(*filters, &block)
            before_filter(*filters, &block)
          end

          def after_action(*filters, &block)
            after_filter(*filters, &block)
          end

          def skip_before_action(*filters, &block)
            skip_before_filter(*filters, &block)
          end
        end
      end
    end
  end
end

unless ActionController::Base.methods.include?(:before_action)
  ActionController::Base.send(:include,Redmineup::Patches::Compatibility::ApplicationControllerPatch)
end
