module Redmineup
  module Patches
    module LiquidPatch
      module StandardFilters

        def self.included(base)
          base.class_eval do
            
            private
    
            def to_number(obj)
              case obj
              when Float
                BigDecimal(obj.to_s)
              when Numeric
                obj
              when String
                (obj.strip =~ /^\d+\.\d+$/) ? BigDecimal(obj) : obj.to_i
              else
                0
              end
            end
          end
        end

      end
    end
  end
end
  
unless Liquid::StandardFilters.included_modules.include?(Redmineup::Patches::LiquidPatch::StandardFilters)
  Liquid::StandardFilters.send(:include, Redmineup::Patches::LiquidPatch::StandardFilters)
end
