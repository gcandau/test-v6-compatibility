class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Translate attribute names for validation errors display
  def self.human_attribute_name(attr, options = {})
    prepared_attr = attr.to_s.sub(/_id$/, '').sub(/^.+\./, '')
    class_prefix = name.underscore.tr('/', '_')
    redmine_default = [
      :"field_#{class_prefix}_#{prepared_attr}",
      :"field_#{prepared_attr}"
    ]
    options[:default] = redmine_default + Array(options[:default])
    super
  end
end
