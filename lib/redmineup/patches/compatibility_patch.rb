if Redmine::VERSION.to_s < "4" 
  require 'redmineup/patches/compatibility/application_controller_patch'
end
if Redmine::VERSION.to_s < "5" 
  require 'redmineup/patches/compatibility/user_patch'
end
require 'redmineup/patches/compatibility/routing_mapper_patch'